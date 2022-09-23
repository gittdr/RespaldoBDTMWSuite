SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_associate_branch_sp] AS

/* Change Control

TGRIFFIT 38795 01/02/2008 created this stored procedure. This is required by the Associate integration piece.
Returns all associate branch details

*/

    SELECT brn_id, brn_name, payto_number
    FROM associate_branch

GO
GRANT EXECUTE ON  [dbo].[d_associate_branch_sp] TO [public]
GO
