module.exports = function(func) {
    return async (res, req, next) => {
        try {
            await func(res, req, next);
        } catch (error) {
            next(error)
        }
    }
}
