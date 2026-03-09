const { createClient } = require('@supabase/supabase-js');

// Configuraciones tomadas de .env
const supabaseUrl = process.env.SUPABASE_URL || 'https://tu-proyecto.supabase.co';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'tu-anon-key';
const supabaseBucket = process.env.SUPABASE_BUCKET || 'media-content'; // El nombre por defecto de tu bucket en Supabase

// Crear cliente de Supabase
const supabase = createClient(supabaseUrl, supabaseKey);

const uploadFile = async (fileObj, folderPath = '') => {
    // Generar un nombre de archivo único, previniendo sobreescrituras (evitando colisión de caché)
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    // Extraer extensión del originalname (e.g. .png o .jpg)
    const ext = fileObj.originalname ? fileObj.originalname.substring(fileObj.originalname.lastIndexOf('.')) : '';
    let objectName = `${uniqueSuffix}${ext}`;

    // Si folderPath tiene valor (e.g. 'users/avatars'), armar el nombre completo
    if (folderPath) {
        // Asegurar que folder termina con barra
        if (!folderPath.endsWith('/')) folderPath += '/';
        objectName = `${folderPath}${objectName}`;
    }

    // Subir el archivo al Storage
    const { data, error } = await supabase.storage
        .from(supabaseBucket)
        .upload(objectName, fileObj.buffer, {
            contentType: fileObj.mimetype,
            upsert: true // IMPORTANTE: permite sobrescribir si el archivo ya existe
        });

    if (error) {
        throw new Error(`Error al subir a Supabase Storage: ${error.message}`);
    }

    // Obtener la URL pública
    const { data: publicUrlData } = supabase.storage
        .from(supabaseBucket)
        .getPublicUrl(objectName);

    return publicUrlData.publicUrl.trim();
};

module.exports = { uploadFile };
