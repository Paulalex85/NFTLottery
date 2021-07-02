const fsPromises = require('fs').promises;

(async () => {
    try {
        const iexecOut = process.env.IEXEC_OUT;
        // rand the index winner
        const index = Math.floor(Math.random() * process.argv[1]);
        console.log(index);
        // Append some results in /iexec_out/
        await fsPromises.writeFile(`${iexecOut}/result.txt`, index);
        // Declare everything is computed
        const computedJsonObj = {
            'deterministic-output-path': `${iexecOut}/result.txt`,
        };
        await fsPromises.writeFile(
            `${iexecOut}/computed.json`,
            JSON.stringify(computedJsonObj),
        );
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
})();