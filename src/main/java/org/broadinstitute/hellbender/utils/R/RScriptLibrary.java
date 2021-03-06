package org.broadinstitute.hellbender.utils.R;

import org.broadinstitute.hellbender.utils.io.IOUtils;
import org.broadinstitute.hellbender.utils.io.Resource;

import java.io.File;

/**
 * Libraries embedded in the StingUtils package.
 */
public enum RScriptLibrary {
    GSALIB("gsalib");

    public final static String R_LIBRARY_SUFFIX = ".tar.gz";

    private final String name;

    private RScriptLibrary(String name) {
        this.name = name;
    }

    public String getLibraryName() {
        return this.name;
    }

    public String getResourcePath() {
        return name + R_LIBRARY_SUFFIX;
    }

    /**
     * Writes the library source code to a temporary tar.gz file and returns the path.
     * @return The path to the library source code.
     */
    public File writeTemp() {
        return IOUtils.writeTempResourceFromPath(getResourcePath(), RScriptLibrary.class);
    }

    /**
     * Retrieve the resource for this library and write it to a temp File in {@code targetDir}. The File is
     * automatically scheduled for deletion on exit.
     * @param targetDir target directory where the File should be written
     * @return the newly created temporary File containing the library
     */
    public File writeLibraryToTempFile(final File targetDir) {
        final File libraryFile = IOUtils.createTempFileInDirectory(getLibraryName(), R_LIBRARY_SUFFIX, targetDir);
        // Note that the temporary filename generated by this ends with the resource path suffix containing
        // embedded digits: ".tar.dddddddddd.gz".
        IOUtils.writeResource(new Resource(getResourcePath(), RScriptLibrary.class), libraryFile);
        return libraryFile;
    }
}
