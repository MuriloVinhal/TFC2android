const petService = require('../services/petService');

const createPet = async (req, res) => {
    try {
        const petData = req.body;
        
        // Validações básicas
        if (!petData.nome || !petData.raca || !petData.idade || !petData.porte || !petData.usuarioId) {
            return res.status(400).json({ 
                message: 'Campos obrigatórios: nome, raca, idade, porte, usuarioId' 
            });
        }
        
        // Foto é opcional - só adicionar se enviada
        if (req.file) {
            petData.foto = `/uploads/pets/${req.file.filename}`;
        }
        
        const newPet = await petService.createPet(petData);
        res.status(201).json({
            message: 'Pet cadastrado com sucesso!',
            pet: newPet
        });
    } catch (error) {
        console.error('Erro ao cadastrar pet:', error);
        res.status(500).json({ message: 'Erro ao cadastrar pet', error: error.message });
    }
};

const getAllPets = async (req, res) => {
    try {
        const { usuarioId } = req.query;
        let pets;
        if (usuarioId) {
            pets = await petService.getPetsByUsuarioId(usuarioId);
        } else {
            pets = await petService.getAllPets();
        }
        res.status(200).json(pets);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao listar pets', error: error.message });
    }
};

const updatePet = async (req, res) => {
    try {
        const { id } = req.params;
        const petData = req.body;
        if (req.file) {
            petData.foto = `/uploads/pets/${req.file.filename}`;
        }
        const petAtualizado = await petService.updatePet(id, petData);
        res.status(200).json(petAtualizado);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao atualizar pet', error: error.message });
    }
};

const deletePet = async (req, res) => {
    try {
        const { id } = req.params;
        await petService.deletePet(id);
        res.status(200).json({ message: 'Pet excluído com sucesso!' });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao excluir pet', error: error.message });
    }
};

module.exports = {
    createPet,
    getAllPets,
    updatePet,
    deletePet,
};