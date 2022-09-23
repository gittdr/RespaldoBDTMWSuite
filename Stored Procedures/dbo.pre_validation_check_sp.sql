SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pre_validation_check_sp]
(@order_id int,
 @invoice_id int,
 @record_type char(1),
 @event_id  int
)
AS

/* Change Control

TGRIFFIT 38797 11/23/2007 created this stored procedure. This will be called by d_get_validation_groups. It has
two responsibilities 1) Decides whether an order/invoice record should be validated (e.g no point validating a Master or Cancelled order) 2) Determines which validation company group should be used in the validation process.
Note: the @rule_name value comes from the vale_pre_validation_rule column of the validation_event table for the event that is being validated. This provides some flexibility if different checks are required for different events. At this time, however, all validation events use the same 'ORD_INV_BILL_TO_CHECK' rule.

*/
    SET NOCOUNT ON
    
    DECLARE @rule_name varchar(255),
            @status varchar(6),
            @bill_to varchar(8),
            @co_grp_id int,
            @co_grp_chk int
            
            SET @co_grp_id = -1
    
    BEGIN

        SELECT @rule_name = vale_pre_validation_rule
        FROM validation_event
        WHERE vale_id = @event_id
        
        IF @rule_name = 'ORD_INV_BILL_TO_CHECK' 
        BEGIN
            SELECT @status = ord_status
            FROM orderheader
            WHERE ord_hdrnumber = @order_id
            
            IF upper(@status) = 'MST' OR upper(@status) = 'CAN'
            BEGIN
              DELETE FROM #record_info
              RETURN  
            END
            
            SELECT @bill_to = 
                CASE @record_type
                    WHEN 'O' THEN
                        (SELECT ord_billto FROM orderheader 
                         WHERE ord_hdrnumber = @order_id)
                    WHEN 'I' THEN
                        (SELECT ivh_billto FROM invoiceheader
                         WHERE ivh_hdrnumber = @invoice_id)
                 END
            
            SELECT @bill_to = ISNULL(@bill_to, '')     
            
            IF @bill_to <> ''
            BEGIN
                SELECT @co_grp_chk = valco_valcg_id
                FROM validation_company
                WHERE valco_cmp_id = @bill_to
                AND valco_used_as = 'BILL'

                IF @co_grp_chk IS NOT NULL
                BEGIN
                    /* 1 TO 1 ENFORCED IN THE APP */                          
                    SELECT @co_grp_id = 
                    (SELECT TOP 1 valco_valcg_id
                    FROM validation_company
                    WHERE valco_cmp_id = @bill_to
                    AND valco_used_as = 'BILL')
                END
            END
        END
    
        UPDATE #record_info
        SET record_co_grp_id = @co_grp_id
        WHERE order_id = @order_id
        AND invoice_id = @invoice_id 
                 
    END
GO
GRANT EXECUTE ON  [dbo].[pre_validation_check_sp] TO [public]
GO
