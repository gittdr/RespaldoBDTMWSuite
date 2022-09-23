SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_fuelpurchased_sp] (@ps_fpid varchar(36))
AS


declare @temp table (mpp_id			varchar(8),
					 trc_number		varchar(8),
					 fp_date		datetime,
					 fp_quantity	money,
					 fp_amount		money,			--5
					 fp_invoice_no	varchar(12),
					 ts_code		varchar(8),
					 fp_city		int,
					 fp_state		varchar(6),
					 stp_number		int,			--10
					 fp_uom			varchar(6),
					 fp_cost_per	money,
					 fp_trc_trl		char(1),
					 cty_nmstct		varchar(25),
					 trl_number		varchar(13),	--15
					 fp_sequence	int,
					 cty_state		varchar(6),
					 fp_id			varchar(36),
					 fp_purchcode	varchar(6),
					 fp_odomoter	decimal(8,1),	--20
					 fp_processeddt	datetime,
					 lgh_number		int,
					 fp_enteredby	varchar(20),
					 fp_processedby	varchar(20),
					 mov_number		int,			--25
					 fp_owner		varchar(12),
					 fp_vendorname	varchar(30),
					 fp_fueltype	varchar(6),
					 fp_status		varchar(6),
					 ord_number		varchar(12),	--30
					 fp_charge_yn	char(1),
					 ord_hdrnumber	int,
					 fp_cityname	varchar(24),
					 fp_contractnum	varchar(25),
					 ccc_revtype1	varchar(6),		--35
					 rowcriteria	varchar(6),
					 fp_cac_id	varchar(10),
					 fp_ccd_id	varchar(10),
					 fp_prevodometer int
					 )

insert into @temp (mpp_id,			
				   trc_number,
				   fp_date,
				   fp_quantity,
				   fp_amount,						--5
				   fp_invoice_no,
				   ts_code,
				   fp_city,
				   fp_state,
				   stp_number,						--10
				   fp_uom,
				   fp_cost_per,
				   fp_trc_trl,
				   cty_nmstct,
				   trl_number,						--15
				   fp_sequence,
				   cty_state,
				   fp_id,
				   fp_purchcode,
				   fp_odomoter,						--20
				   fp_processeddt,
				   lgh_number,
				   fp_enteredby,
				   fp_processedby,
				   mov_number,						--25
				   fp_owner,
				   fp_vendorname,
				   fp_fueltype,
				   fp_status,
				   ord_number,						--30
				   fp_charge_yn,
				   ord_hdrnumber,
				   fp_cityname,
				   fp_contractnum,
				   ccc_revtype1,					--35
				   rowcriteria,
				   fp_cac_id,
				   fp_ccd_id,
				   fp_prevodometer
				   )
  select fuelpurchased.mpp_id,   
         fuelpurchased.trc_number,   
         fuelpurchased.fp_date,   
         fuelpurchased.fp_quantity,   
         fuelpurchased.fp_amount,   
         fuelpurchased.fp_invoice_no,   
         fuelpurchased.ts_code,   
         fuelpurchased.fp_city,   
         fuelpurchased.fp_state,   
         fuelpurchased.stp_number,   
         fuelpurchased.fp_uom,   
         fuelpurchased.fp_cost_per,   
         fuelpurchased.fp_trc_trl,   
         city.cty_nmstct,   
         fuelpurchased.trl_number,   
         fuelpurchased.fp_sequence,   
         city.cty_state,   
         fuelpurchased.fp_id,   
         fuelpurchased.fp_purchcode,   
         fuelpurchased.fp_odometer,   
         fuelpurchased.fp_processeddt,   
         fuelpurchased.lgh_number,   
         fuelpurchased.fp_enteredby,   
         fuelpurchased.fp_processedby,   
         fuelpurchased.mov_number,   
         fuelpurchased.fp_owner,   
         fuelpurchased.fp_vendorname,   
         fuelpurchased.fp_fueltype,   
         fuelpurchased.fp_status,   
         fuelpurchased.ord_number,   
         fuelpurchased.fp_charge_yn,   
         fuelpurchased.ord_hdrnumber,   
         fuelpurchased.fp_cityname,   
         fuelpurchased.fp_contractnum,
		 cdcustcode.ccc_revtype1,
		 NULL,
		fuelpurchased.fp_cac_id,
		fuelpurchased.fp_ccd_id,
		fuelpurchased.fp_prevodometer
    FROM fuelpurchased 
    LEFT OUTER JOIN cdcustcode on fuelpurchased.fp_ccd_id = cdcustcode.ccc_id and fuelpurchased.fp_cac_id = cdcustcode.cac_id
    LEFT OUTER JOIN orderheader on fuelpurchased.ord_hdrnumber = orderheader.ord_hdrnumber
    LEFT OUTER JOIN city ON fuelpurchased.fp_city = city.cty_code
   WHERE fuelpurchased.fp_id = @ps_fpid
ORDER BY fuelpurchased.fp_sequence ASC   

--PTS 51570 JJF 20100720
----Now get the rowrestriction criteria
----first get the restriction by the customer code on the fuelpurchased record
--update @temp
--   set rowcriteria = ccc_revtype1
-- where ccc_revtype1 is not null
DELETE	@temp
FROM	@temp fp
		INNER JOIN cdcustcode ccd on fp.fp_ccd_id = ccd.ccc_id and fp.fp_cac_id = ccd.cac_id
WHERE	dbo.RowRestrictByUser('cdcustcode', ccd.rowsec_rsrv_id, '', '', '') = 0
		AND ccd.ccc_revtype1 is not null

----if that is not available then get the restriction from the ordernumber
--update @temp
--   set rowcriteria = orderheader.ord_revtype1
--  from orderheader, @temp t
-- where t.ord_hdrnumber = orderheader.ord_hdrnumber
--   and isnull(orderheader.ord_hdrnumber,0) > 0
--   and t.rowcriteria is null

----if that is not available then get it from the tractor
--update @temp
--   set rowcriteria = tractorprofile.trc_terminal
--  from tractorprofile, @temp t
--where t.trc_number = tractorprofile.trc_number
--   and isnull(t.trc_number,'UNKNOWN') <> 'UNKNOWN'
--   and t.rowcriteria is null

----if that is not available then get it from the driver
--update @temp
--   set rowcriteria = manpowerprofile.mpp_terminal
--  from manpowerprofile, @temp t
-- where t.mpp_id = manpowerprofile.mpp_id
--   and isnull(t.mpp_id,'UNKNOWN') <> 'UNKNOWN'
--   and t.rowcriteria is null

----if that is not available then get it from the trailer
--update @temp
--   set rowcriteria = trailerprofile.trl_terminal
--  from trailerprofile, @temp t
-- where t.trl_number = trailerprofile.trl_id
--   and isnull(t.trl_number,'UNKNOWN') <> 'UNKNOWN'
--   and t.rowcriteria is null
   
--END PTS 51570 JJF 20100720   

select mpp_id,			
	   trc_number,
	   fp_date,
	   fp_quantity,
	   fp_amount,						--5
	   fp_invoice_no,
	   ts_code,
	   fp_city,
	   fp_state,
	   stp_number,						--10
	   fp_uom,
	   fp_cost_per,
	   fp_trc_trl,
	   cty_nmstct,
	   trl_number,						--15
	   fp_sequence,
	   cty_state,
	   fp_id,
	   fp_purchcode,
	   fp_odomoter,						--20
	   fp_processeddt,
	   lgh_number,
	   fp_enteredby,
	   fp_processedby,
	   mov_number,						--25
	   fp_owner,
	   fp_vendorname,
	   fp_fueltype,
	   fp_status,
	   ord_number,						--30
	   fp_charge_yn,
	   ord_hdrnumber,
	   fp_cityname,
	   fp_contractnum,
	   ccc_revtype1,					--35
	   rowcriteria,
	   fp_prevodometer	   
  from @temp
--PTS 51570 JJF 20100720
--where dbo.RowRestrictByUser(rowcriteria, '', '', '') = 1
--END PTS 51570 JJF 20100720

GO
GRANT EXECUTE ON  [dbo].[d_fuelpurchased_sp] TO [public]
GO
