SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[d_stlmnt_det_final_sp_JR] (@phnum INT, @type CHAR(6), @id CHAR(13), @paydate DATETIME, @numperiodo int)
AS
/* Revision History:
 
*/

DECLARE	@v_PerDiemPaytype varchar(60),
		@paydatecheck char(1),		-- PTS 31375 -- BL
		@CollectDate2359 char(1)	-- vjh 66177


DECLARE @Detalle_rows TABLE(
		detallepago_id		numeric NULL)

SELECT @paydate = convert(datetime, @paydate, 111)


SELECT  @v_PerDiemPaytype = IsNull(gi_string1, '')
FROM  generalinfo
WHERE gi_name = 'PerDiemPaytype'

-- PTS 31375 -- BL 
SELECT @paydatecheck = LEFT(upper(IsNull(gi_string1, 'N')), 1)
FROM  generalinfo
WHERE gi_name = 'UseTransDateInCollect'

--vjh 66177
SELECT	@CollectDate2359 = LEFT(upper(gi_string1), 1)
FROM	generalinfo
WHERE	gi_name = 'CollectDate2359'
if @CollectDate2359 = null select @CollectDate2359 = 'N'
if @CollectDate2359 = 'Y' select @paydate = CONVERT(VARCHAR(10), @paydate, 101) + ' 23:59:59'

select @paydate = CONVERT(VARCHAR(10), @paydate, 111) + ' 00:00:00'
PRINT 'fecha '+cast( @paydate as varchar(20))
PRINT 'Periodo '+cast( @numperiodo as varchar(5))
PRINT 'fecha2 ' +convert(varchar(10),@paydate,111)


   INSERT INTO @Detalle_rows (detallepago_id)
    SELECT   pyd_number
     FROM  paydetail  LEFT OUTER JOIN  orderheader  ON  paydetail.ord_hdrnumber  = orderheader.ord_hdrnumber
                  LEFT OUTER JOIN  purchaseservicedetail  ON  paydetail.psd_number  = purchaseservicedetail.psd_number
                  Left Outer join legheader on paydetail.lgh_number = legheader.lgh_number
                  LEFT OUTER JOIN manpowerprofile on paydetail.asgn_id = manpowerprofile.mpp_id and paydetail.asgn_type = 'DRV'
                  LEFT OUTER JOIN tractorprofile on paydetail.asgn_id = tractorprofile.trc_number and paydetail.asgn_type = 'TRC',
           paytype
               LEFT OUTER JOIN paytypetax ON paytype.pyt_number = paytypetax.pyt_number
    WHERE   (pyh_number = 0 AND
          asgn_id = @id AND
          asgn_type = @type AND
          ((pyd_status = 'PND' AND
            pyh_payperiod >= '20491231 00:00:00' AND
            case @paydatecheck when 'Y' Then pyd_transdate else '19500101' end <=  @paydate) OR
           (pyd_status = 'PND' AND
            pyh_payperiod =  @paydate) OR
           (pyd_status = 'HLD' AND
            (pyd_workperiod <=  @paydate OR
            pyd_workperiod >= '20491231 23:59')) OR
           (pyd_status = 'HLD' AND
            pyt_agedays > 0 AND
            DATEADD(day, pyt_agedays, pyd_transdate) <  @paydate))) AND
         paydetail.pyt_itemcode = paytype.pyt_itemcode

-- actualiza cada uno de los paydetail
--select * from @Detalle_rows

UPDATE paydetail 
SET pyd_status = 'PND', pyh_payperiod =  @paydate, pyd_workperiod =  @paydate, psd_id = @numperiodo, pyd_releasedby = 'LOPEZ' 
WHERE pyd_number in (select detallepago_id from @Detalle_rows)
GO
