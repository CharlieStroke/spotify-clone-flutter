const getPagination = (req) => {
    let { page = 1, limit = 10 } = req.query;

    page = parseInt(page);
    limit = parseInt(limit);

    if (isNaN(page) || page < 1) {
        page = 1;
    }
    
    if (isNaN(limit) || limit < 1 || limit > 50) {
        limit = 10;
    }

    const offset = (page - 1) * limit;
    return { limit, offset, page };
}

module.exports = {
    getPagination
}