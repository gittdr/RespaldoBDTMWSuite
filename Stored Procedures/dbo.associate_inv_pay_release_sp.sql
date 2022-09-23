SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[associate_inv_pay_release_sp]
(
@mov_ord_id int,
@model varchar(20),
@allow varchar(1),
@user varchar(20)
 ) 
 AS
/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

DECLARE @return int

SELECT @model = upper(@model),
       @allow = upper(@allow),
       @user = upper(@user)

IF @model = 'INV' or @model = 'STL'
    BEGIN
        IF EXISTS (SELECT 1 FROM associate_inv_pay_release WHERE type = @model AND id = @mov_ord_id)
            UPDATE associate_inv_pay_release
            SET allow_release = @allow, updatedby = @user, updated = GETDATE()
            WHERE type = @model AND id = @mov_ord_id
        ELSE
            INSERT INTO associate_inv_pay_release (type, id, allow_release, created, createdby)
            SELECT @model, @mov_ord_id, @allow, GETDATE(), @user

        IF @@error = 0
            SELECT @return = 0
        ELSE
            SELECT @return = -1
    END
ELSE IF @model = 'ALL'
    BEGIN
        UPDATE associate_inv_pay_release
        SET allow_release = @allow, updatedby = @user, updated = GETDATE()
        WHERE type = 'STL' AND id = @mov_ord_id

        IF @@error = 0
        BEGIN
            UPDATE associate_inv_pay_release
            SET allow_release = @allow, updatedby = @user, updated = GETDATE()
            FROM associate_inv_pay_release a INNER JOIN orderheader o
                ON a.id = o.ord_hdrnumber
                AND a.type = 'INV'
            WHERE o.mov_number = @mov_ord_id
              
            IF @@error = 0
               SELECT @return = 0
            ELSE
                SELECT @return = -1
       END
       ELSE
           SELECT @return = -1
    END
ELSE
    SELECT @return = -2

return @return
GO
GRANT EXECUTE ON  [dbo].[associate_inv_pay_release_sp] TO [public]
GO
