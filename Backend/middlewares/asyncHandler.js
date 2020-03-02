// TODO implement winston error logging here

module.exports = (func, context) => async (req, res, next) => {
    try {
        return await func.call(context, req, res);
    } catch (error) {
        console.log(error)
        if (error.errors) {
            let message = 'Errors: '
            for (const field in error.errors) {
                message += `\n ${error.errors[field].message}`;
            }
            res.status(400).send({ message })
        } else {
            res.status(500).send('Internal server error');
        }
    }
}
