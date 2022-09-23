SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[check_if_whole_move_settled_sp] 
(
@mov_number int, 
@result varchar(3) OUT
) 
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.
Returns all associate topup branches

*/

IF EXISTS (SELECT 1 FROM legheader lg
            WHERE mov_number = @mov_number
            AND NOT EXISTS (SELECT 1 FROM paydetail pd WHERE pd.lgh_number = lg.lgh_number))
   SELECT @result = 'NO'
else
   SELECT @result = 'YES'

GO
GRANT EXECUTE ON  [dbo].[check_if_whole_move_settled_sp] TO [public]
GO
