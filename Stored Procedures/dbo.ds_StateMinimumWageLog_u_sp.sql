SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[ds_StateMinimumWageLog_u_sp]
( @smwlh_id                      INT
, @processed_pay_period          DATETIME
, @applicable_pay_period_begin   DATETIME
, @applicable_pay_period_end     DATETIME
, @smwld_id                      INT
, @mpp_id                        VARCHAR(8)
, @applicable_taxable_pay        MONEY
, @applicable_duty_hours         DECIMAL(10,4)
, @smw_id                        INT
, @adjusted_amount               MONEY
)
AS

/*
*
*
* NAME:
* dbo.ds_StateMinimumWageLog_u_sp
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Stored Procedure to update rows into stateminimumwagelog_hdr and stateminimumwagelog_dtl
*
* RETURNS:
*
* NOTHING:
*
* 08/15/2012 PTS63639 SPN - Created Initial Version
*
*/

SET NOCOUNT ON

BEGIN

   RAISERROR('Update not allowed',16,1)
   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[ds_StateMinimumWageLog_u_sp] TO [public]
GO
