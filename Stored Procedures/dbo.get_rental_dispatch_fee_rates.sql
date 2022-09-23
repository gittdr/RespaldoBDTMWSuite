SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[get_rental_dispatch_fee_rates] 
(   @ctr_brn_country char(2), 
    @trl_brn_country char(2), 
    @trailer_rent varchar(20) OUT, 
    @dispatch_fee varchar(20) OUT
)
AS

/* Change Control

TGRIFFIT 38795 12/18/2007 created this stored procedure. This is required by the Associate integration piece.

*/

    IF @ctr_brn_country = 'US'
    BEGIN
        SELECT @dispatch_fee = gi_string1 FROM generalinfo
        WHERE gi_name = 'US_DISP_FEE'
    END
    ELSE IF @ctr_brn_country = 'CA'
    BEGIN
        SELECT @dispatch_fee = gi_string1 FROM generalinfo
        WHERE gi_name = 'CAN_DISP_FEE'
    END
    ELSE
        SELECT @dispatch_fee = '0'
    
    
    IF @trl_brn_country = 'US'
    BEGIN
        SELECT @trailer_rent = gi_string1 FROM generalinfo
        WHERE gi_name = 'US_TRL_RENT'
    END
    ELSE IF @trl_brn_country = 'CA'
    BEGIN
        SELECT @trailer_rent = gi_string1 FROM generalinfo
        WHERE gi_name = 'CAN_TRL_RENT'
    END
    ELSE
        SELECT @trailer_rent = '0'

GO
GRANT EXECUTE ON  [dbo].[get_rental_dispatch_fee_rates] TO [public]
GO
