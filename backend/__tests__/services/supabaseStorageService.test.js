jest.mock('@supabase/supabase-js', () => {
    const upload = jest.fn();
    const getPublicUrl = jest.fn();
    const from = jest.fn().mockReturnValue({ upload, getPublicUrl });
    const createClient = jest.fn().mockReturnValue({ storage: { from } });
    return { createClient, __upload: upload, __getPublicUrl: getPublicUrl, __from: from };
});

const supabaseJs = require('@supabase/supabase-js');
const { uploadFile } = require('../../src/services/supabaseStorageService');

const makeFile = (name = 'file.png') => ({
    buffer: Buffer.from('data'),
    mimetype: 'image/png',
    originalname: name,
});

beforeEach(() => jest.clearAllMocks());

describe('uploadFile', () => {
    test('devuelve URL pública recortada en caso de éxito', async () => {
        supabaseJs.__upload.mockResolvedValueOnce({ data: {}, error: null });
        supabaseJs.__getPublicUrl.mockReturnValueOnce({ data: { publicUrl: '  https://cdn.example.com/file.png  ' } });

        const url = await uploadFile(makeFile(), 'covers/albums');

        expect(url).toBe('https://cdn.example.com/file.png');
        expect(supabaseJs.__upload).toHaveBeenCalledWith(
            expect.stringMatching(/^covers\/albums\//),
            expect.any(Buffer),
            { contentType: 'image/png' }
        );
    });

    test('añade slash final al folderPath si no lo tiene', async () => {
        supabaseJs.__upload.mockResolvedValueOnce({ data: {}, error: null });
        supabaseJs.__getPublicUrl.mockReturnValueOnce({ data: { publicUrl: 'https://cdn.example.com/songs/tracks/file.mp3' } });

        await uploadFile({ buffer: Buffer.from(''), mimetype: 'audio/mpeg', originalname: 'song.mp3' }, 'songs/tracks');

        const objectName = supabaseJs.__upload.mock.calls[0][0];
        expect(objectName).toMatch(/^songs\/tracks\//);
    });

    test('funciona sin folderPath (objeto en la raíz del bucket)', async () => {
        supabaseJs.__upload.mockResolvedValueOnce({ data: {}, error: null });
        supabaseJs.__getPublicUrl.mockReturnValueOnce({ data: { publicUrl: 'https://cdn.example.com/file.png' } });

        const url = await uploadFile(makeFile());

        expect(url).toBe('https://cdn.example.com/file.png');
        const objectName = supabaseJs.__upload.mock.calls[0][0];
        expect(objectName).not.toContain('/');
    });

    test('maneja archivo sin extensión', async () => {
        supabaseJs.__upload.mockResolvedValueOnce({ data: {}, error: null });
        supabaseJs.__getPublicUrl.mockReturnValueOnce({ data: { publicUrl: 'https://cdn.example.com/noext' } });

        await uploadFile({ buffer: Buffer.from(''), mimetype: 'application/octet-stream', originalname: 'noext' }, '');

        const objectName = supabaseJs.__upload.mock.calls[0][0];
        expect(objectName).not.toContain('.');
    });

    test('lanza error cuando Supabase devuelve un error de subida', async () => {
        supabaseJs.__upload.mockResolvedValueOnce({ data: null, error: { message: 'Bucket not found' } });

        await expect(uploadFile(makeFile(), 'covers')).rejects.toThrow(
            'Error al subir a Supabase Storage: Bucket not found'
        );
    });
});
