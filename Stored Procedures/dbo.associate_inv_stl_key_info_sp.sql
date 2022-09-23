SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[associate_inv_stl_key_info_sp]
(
 @mov_number int,
 @associate_pay varchar(50) out,
 @inv_status varchar(50) out,
 @inv_on_black_list char(1) out,
 @stl_on_black_list char(1) out,
 @orders_in_move    int     out,
 @legs_in_move      int     out,
 @error         varchar(50) out
 ) 
 AS
/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/
SELECT @error = ''

IF (SELECT COUNT(DISTINCT ord_revtype1) FROM orderheader WHERE mov_number = @mov_number) > 1
    SELECT @error = 'MULTIPLE_CONTROL_BRANCHES'
ELSE
BEGIN
    SELECT @orders_in_move = COUNT(DISTINCT ord_hdrnumber) FROM orderheader WHERE mov_number = @mov_number
    SELECT @legs_in_move   = COUNT(DISTINCT lgh_number) FROM legheader WHERE mov_number = @mov_number

    IF EXISTS (SELECT 1 FROM associate_pay_entry WHERE mov_number = @mov_number AND ape_status = 'PND')
        SELECT @associate_pay = 'NOT_ALL_TRANSFERRED'
    ELSE IF EXISTS (SELECT 1 FROM associate_pay_entry WHERE mov_number = @mov_number AND ape_status = 'XFR')

        SELECT @associate_pay = 'ALL_TRANSFERRED'
    ELSE IF EXISTS (SELECT 1 FROM legheader l WHERE mov_number = @mov_number
                    AND NOT EXISTS (SELECT 1 FROM paydetail p WHERE p.lgh_number = l.lgh_number))
        SELECT @associate_pay = 'MOVE_STLMNT_NOT_DONE'
    ELSE IF EXISTS (SELECT 1 FROM paydetail  WHERE mov_number = @mov_number AND pyd_status = 'XFR')
    BEGIN
        IF EXISTS (SELECT 1 FROM paydetail  WHERE mov_number = @mov_number AND pyd_status <> 'XFR')
            SELECT @associate_pay = 'XFR_NON_XFR_MIX_STLMNT_WITHOUT_ASSO_PAY'
        ELSE
            SELECT @associate_pay = 'XFR_STLMNT_WITHOUT_ASSO_PAY'
    END
    ELSE
        SELECT @associate_pay = 'NON_XFR_STLMNT_WITHOUT_ASSO_PAY'


    IF (@associate_pay = 'NOT_ALL_TRANSFERRED' or @associate_pay = 'ALL_TRANSFERRED') AND
       NOT EXISTS (SELECT 1 FROM associate_pay_entry WHERE mov_number = @mov_number AND entry_type = 'CURR')
       SELECT @error = 'ASSO_PAY_CURRENT_ENTRY_MISSING'

    ELSE
    BEGIN

        IF EXISTS (SELECT 1 FROM orderheader o
                    WHERE o.mov_number = @mov_number
                      AND NOT EXISTS (SELECT 1 FROM invoiceheader i WHERE o.ord_hdrnumber = i.ord_hdrnumber ))
            SELECT @inv_status = 'NOT_ALL_INVOICED'
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM orderheader o INNER JOIN invoiceheader i 
                        ON o.ord_hdrnumber = i.ord_hdrnumber
                        WHERE o.mov_number = @mov_number 
                        AND ivh_invoicestatus <> 'XFR')
                SELECT @inv_status = 'NOT_ALL_TRANSFERRED'
            ELSE
                SELECT @inv_status = 'ALL_TRANSFERRED'

        END

        IF EXISTS (SELECT 1 FROM associate_inv_pay_release l INNER JOIN orderheader o
                    ON o.ord_hdrnumber = l.id AND l.type = 'INV' AND l.allow_release = 'N'
                    WHERE  o.mov_number = @mov_number)
            SELECT @inv_on_black_list = 'Y'
        ELSE
            SELECT @inv_on_black_list = 'N'

        IF EXISTS (SELECT 1 FROM associate_inv_pay_release
                    WHERE id = @mov_number AND type = 'STL' AND allow_release = 'N')
            SELECT @stl_on_black_list = 'Y'
        ELSE
            SELECT @stl_on_black_list = 'N'
    END

END

GO
GRANT EXECUTE ON  [dbo].[associate_inv_stl_key_info_sp] TO [public]
GO
