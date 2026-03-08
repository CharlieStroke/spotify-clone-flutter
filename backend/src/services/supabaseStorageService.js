const { createClient } = require('@supabase/supabase-js');

// Configuraciones tomadas de .env
const supabaseUrl = process.env.SUPABASE_URL || 'https://tu-proyecto.supabase.co';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'tu-anon-key';
const supabaseBucket = process.env.SUPABASE_BUCKET || 'spotify-clone-bucket'; // El nombre por defecto de tu bucket en Supabase

// Crear cliente de Supabase
const supabase = createClient(supabaseUrl, supabaseKey);

const uploadFile = async (fileBuffer, objectName, contentType) => {
    // Subir el archivo al Storage (objectName puede contener subcarpetas como songs/ o covers/)
    const { data, error } = await supabase.storage
        .from(supabaseBucket)
        .upload(objectName, fileBuffer, {
            contentType: contentType,
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
