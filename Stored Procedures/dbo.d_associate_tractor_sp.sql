SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_tractor_sp] AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Returns all associate tractor information.
TGRIFFIT 42177 06/11/2008 - change to include the tractor's branch in the result set.

*/

    SELECT  associate_tractor.trc_number,
            associate_tractor.type,
            tractorprofile.trc_terminal
    FROM associate_tractor
        INNER JOIN tractorprofile
            ON associate_tractor.trc_number = tractorprofile.trc_number
    ORDER BY associate_tractor.trc_number

GO
GRANT EXECUTE ON  [dbo].[d_associate_tractor_sp] TO [public]
GO
