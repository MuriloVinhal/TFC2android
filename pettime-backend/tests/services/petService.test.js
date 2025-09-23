const petService = require('../../src/services/petService');
const db = require('../../src/models');

// Mock the database models
jest.mock('../../src/models', () => ({
  Pet: {
    create: jest.fn(),
    findAll: jest.fn(),
    findByPk: jest.fn(),
    destroy: jest.fn(),
  },
}));

describe('Pet Service Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('createPet', () => {
    test('should create a new pet successfully', async () => {
      const petData = {
        nome: 'Rex',
        raca: 'Labrador',
        idade: 3,
        peso: 25.5,
        usuarioId: 1
      };

      const mockPet = { id: 1, ...petData };
      db.Pet.create.mockResolvedValue(mockPet);

      const result = await petService.createPet(petData);

      expect(db.Pet.create).toHaveBeenCalledWith(petData);
      expect(result).toEqual(mockPet);
    });

    test('should throw error when pet creation fails', async () => {
      const petData = { nome: 'Rex' };
      const errorMessage = 'Database error';
      
      db.Pet.create.mockRejectedValue(new Error(errorMessage));

      await expect(petService.createPet(petData)).rejects.toThrow('Error creating pet: Database error');
    });
  });

  describe('getAllPets', () => {
    test('should return all non-deleted pets', async () => {
      const mockPets = [
        { id: 1, nome: 'Rex', deletado: false },
        { id: 2, nome: 'Bella', deletado: false }
      ];

      db.Pet.findAll.mockResolvedValue(mockPets);

      const result = await petService.getAllPets();

      expect(db.Pet.findAll).toHaveBeenCalledWith({ where: { deletado: false } });
      expect(result).toEqual(mockPets);
    });

    test('should throw error when fetching pets fails', async () => {
      const errorMessage = 'Database connection error';
      
      db.Pet.findAll.mockRejectedValue(new Error(errorMessage));

      await expect(petService.getAllPets()).rejects.toThrow('Error fetching pets: Database connection error');
    });
  });

  describe('getPetById', () => {
    test('should return pet when found', async () => {
      const mockPet = { id: 1, nome: 'Rex', raca: 'Labrador' };
      
      db.Pet.findByPk.mockResolvedValue(mockPet);

      const result = await petService.getPetById(1);

      expect(db.Pet.findByPk).toHaveBeenCalledWith(1);
      expect(result).toEqual(mockPet);
    });

    test('should throw error when pet not found', async () => {
      db.Pet.findByPk.mockResolvedValue(null);

      await expect(petService.getPetById(999)).rejects.toThrow('Error fetching pet: Pet not found');
    });

    test('should throw error when database query fails', async () => {
      const errorMessage = 'Database error';
      
      db.Pet.findByPk.mockRejectedValue(new Error(errorMessage));

      await expect(petService.getPetById(1)).rejects.toThrow('Error fetching pet: Database error');
    });
  });

  describe('updatePet', () => {
    test('should update pet successfully', async () => {
      const petId = 1;
      const updateData = { nome: 'Rex Updated', peso: 30.0 };
      
      const mockPet = {
        id: petId,
        nome: 'Rex',
        peso: 25.5,
        update: jest.fn().mockResolvedValue(true)
      };

      db.Pet.findByPk.mockResolvedValue(mockPet);

      const result = await petService.updatePet(petId, updateData);

      expect(db.Pet.findByPk).toHaveBeenCalledWith(petId);
      expect(mockPet.update).toHaveBeenCalledWith(updateData);
      expect(result).toEqual(mockPet);
    });

    test('should throw error when pet not found for update', async () => {
      db.Pet.findByPk.mockResolvedValue(null);

      await expect(petService.updatePet(999, { nome: 'Test' })).rejects.toThrow('Error updating pet: Pet not found');
    });

    test('should throw error when update fails', async () => {
      const mockPet = {
        update: jest.fn().mockRejectedValue(new Error('Update failed'))
      };
      
      db.Pet.findByPk.mockResolvedValue(mockPet);

      await expect(petService.updatePet(1, { nome: 'Test' })).rejects.toThrow('Error updating pet: Update failed');
    });
  });

  describe('deletePet', () => {
    test('should soft delete pet successfully', async () => {
      const petId = 1;
      
      const mockPet = {
        id: petId,
        deletado: false,
        update: jest.fn().mockResolvedValue(true)
      };

      db.Pet.findByPk.mockResolvedValue(mockPet);

      const result = await petService.deletePet(petId);

      expect(db.Pet.findByPk).toHaveBeenCalledWith(petId);
      expect(mockPet.update).toHaveBeenCalledWith({ deletado: true });
      expect(result).toEqual({"message": "Pet excluído logicamente com sucesso"});
    });

    test('should throw error when pet not found for deletion', async () => {
      db.Pet.findByPk.mockResolvedValue(null);

      await expect(petService.deletePet(999)).rejects.toThrow('Error deleting pet: Pet not found');
    });
  });

  describe('getPetsByUsuarioId', () => {
    test('should return pets for specific user', async () => {
      const usuarioId = 1;
      const mockPets = [
        { id: 1, nome: 'Rex', usuarioId: 1, deletado: false },
        { id: 2, nome: 'Bella', usuarioId: 1, deletado: false }
      ];

      db.Pet.findAll.mockResolvedValue(mockPets);

      const result = await petService.getPetsByUsuarioId(usuarioId);

      expect(db.Pet.findAll).toHaveBeenCalledWith({ 
        where: { usuarioId: usuarioId, deletado: false } 
      });
      expect(result).toEqual(mockPets);
    });

    test('should return empty array when user has no pets', async () => {
      db.Pet.findAll.mockResolvedValue([]);

      const result = await petService.getPetsByUsuarioId(999);

      expect(result).toEqual([]);
    });
  });
});