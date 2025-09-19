const db = require('../models');
const Pet = db.Pet;

const createPet = async (petData) => {
    try {
        const pet = await Pet.create(petData);
        return pet;
    } catch (error) {
        throw new Error('Error creating pet: ' + error.message);
    }
};

const getAllPets = async () => {
    try {
        const pets = await Pet.findAll({ where: { deletado: false } });
        return pets;
    } catch (error) {
        throw new Error('Error fetching pets: ' + error.message);
    }
};

const getPetById = async (id) => {
    try {
        const pet = await Pet.findByPk(id);
        if (!pet) {
            throw new Error('Pet not found');
        }
        return pet;
    } catch (error) {
        throw new Error('Error fetching pet: ' + error.message);
    }
};

const updatePet = async (id, petData) => {
    try {
        const pet = await Pet.findByPk(id);
        if (!pet) {
            throw new Error('Pet not found');
        }
        await pet.update(petData);
        return pet;
    } catch (error) {
        throw new Error('Error updating pet: ' + error.message);
    }
};

const deletePet = async (id) => {
    try {
        const pet = await Pet.findByPk(id);
        if (!pet) {
            throw new Error('Pet not found');
        }
        await pet.update({ deletado: true });
        return { message: 'Pet excluído logicamente com sucesso' };
    } catch (error) {
        throw new Error('Error deleting pet: ' + error.message);
    }
};

const getPetsByUsuarioId = async (usuarioId) => {
    try {
        const pets = await Pet.findAll({ where: { usuarioId, deletado: false } });
        return pets;
    } catch (error) {
        throw new Error('Error fetching pets by usuarioId: ' + error.message);
    }
};

module.exports = {
    createPet,
    getAllPets,
    getPetById,
    updatePet,
    deletePet,
    getPetsByUsuarioId
};