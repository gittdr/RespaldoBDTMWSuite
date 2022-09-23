SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_pay_collectdeductions_sp]
(
@AsgnType	VARCHAR(3),
@AsgnID		VARCHAR(13),
@PayDate	DATETIME,
@Trips		INTEGER,
@Miles		INTEGER,
@Hours		INTEGER
)
AS

/*
replace the inline SQL in the d_pay_collectdeductions datawindow with this proc to support more complex retrieval required
by PTS 74719

Sample call

execute dbo.d_pay_collectdeductions_sp   @AsgnType = 'DRV', @AsgnID = 'HANS', @PayDate = {ts '2014-05-12 00:00:00.000'}, @Trips = 1, @Miles = 1, @Hours = 0


*/
DECLARE @deductionlist TABLE
(
  std_number int,
  std_sequential_loan char(1),
  std_lastdeddate datetime,
  std_issuedate datetime
)
declare @first_sequential_deduction int

--74719 change select to select all of the non-sequential loand records as was always done, and now include ALL of the sequential loans

insert @deductionlist
SELECT  standingdeduction.std_number, COALESCE(standingdeduction.std_sequential_loan, 'N'), standingdeduction.std_lastdeddate, standingdeduction.std_issuedate
		
FROM standingdeduction 
join stdmaster on stdmaster.sdm_itemcode = standingdeduction.sdm_itemcode	
WHERE standingdeduction.asgn_type = @AsgnType
		and standingdeduction.asgn_id = @AsgnID
		and standingdeduction.std_status in ('INI' , 'DRN')
		and (((stdmaster.sdm_deductionterm in ('PAY' , 'SCH', 'SUB')) 
		and ((standingdeduction.std_lastdeddate < @PayDate) or standingdeduction.std_sequential_loan = 'Y')) 
		or  ((stdmaster.sdm_deductionterm = 'QTYTRP') and (@Trips > 0)) 
		or  ((stdmaster.sdm_deductionterm = 'QTYEAR')) 
		or  ((stdmaster.sdm_deductionterm = 'QTYMIL') and (@Miles > 0)) 
		or  ((stdmaster.sdm_deductionterm = 'QTYHRS') and (@Hours > 0))
		or  (stdmaster.sdm_deductionterm = 'LHREV'))
		and isnull(sdm_Garnishment,'N') <> 'Y'	--vjh 63106
-- vjh 34678
-- If the super secret GI setting = 2, then only
-- PAY and SCH need to meet lastdeddate requirement
-- which is why the date check was left in above.
-- If it does not exist, or exists and =1, then
-- all terms must meet lastdeddate requirement
-- which is why the date check is included below
and	(
			(
			exists(select 1 from generalinfo where gi_name='UseLastDedDate')
			and (select isnull(gi_string1,1) from generalinfo where gi_name='UseLastDedDate') = '2'
			)
		or
			(
			((standingdeduction.std_lastdeddate < @PayDate) or standingdeduction.std_sequential_loan = 'Y')
			and	(
					not exists(select 1 from generalinfo where gi_name='UseLastDedDate')
					or	(
						exists(select 1 from generalinfo where gi_name='UseLastDedDate')
						and (select isnull(gi_string1,1) from generalinfo where gi_name='UseLastDedDate') = '1'
						)
					)
			)
		)

--74719 now, filter out (delete) rows from the table variable for any sequential loans that should not be done
--and update the sequential loan record with a lastdeddate of previous pay period end

--See if there is an active sequential loan
select @first_sequential_deduction = min(std_number) from @deductionlist where std_sequential_loan='Y' and std_lastdeddate < '2049/12/31'
if @first_sequential_deduction is not null begin
	--there is an active sequential loan.  Discard other sequential loans from  processing
	delete @deductionlist where std_sequential_loan='Y' and std_number <> @first_sequential_deduction
end else begin
	--there is no active sequential loan.  Find the first, make active and discard the remaining sequential loans from processing
	select top 1 @first_sequential_deduction = std_number from @deductionlist where std_sequential_loan='Y' order by std_issuedate asc
	if @first_sequential_deduction is not null begin
		-- there is one
		delete @deductionlist where std_sequential_loan='Y' and std_number <> @first_sequential_deduction
		--still need to update the original standingdeduciton record with a lastdeddate of the end of the previous period (or issue date if no previous period)
		update standingdeduction set std_lastdeddate = dateadd(day, -7, @paydate) where std_number = @first_sequential_deduction
	end 
	--nothing needs done if there are no sequential loans
end


SELECT  standingdeduction.std_number AS standingdeduction_std_number,
		standingdeduction.std_description AS standingdeduction_std_description,
		stdmaster.pyt_itemcode AS stdmaster_pyt_itemcode,
		standingdeduction.std_priority AS standingdeduction_std_priority,
		stdmaster.sdm_deductionterm AS stdmaster_sdm_deductionterm,
		stdmaster.sdm_deductionbasis AS stdmaster_sdm_deductionbasis,
		stdmaster.sdm_deductionqty AS stdmaster_sdm_deductionqty,
		standingdeduction.std_lastdeddate AS standingdeduction_std_lastdeddate,
		standingdeduction.std_lastdedqty AS standingdeduction_std_lastdedqty,
		standingdeduction.std_status AS standingdeduction_std_status,
		standingdeduction.std_balance AS standingdeduction_std_balance,
		standingdeduction.std_endbalance AS standingdeduction_std_endbalance,
		standingdeduction.std_deductionrate AS standingdeduction_std_deductionrate,
		paytype_a.pyt_pretax AS paytype_pyt_pretax,
		paytype_a.pyt_minus AS paytype_pyt_minus,
		stdmaster.sdm_allowancepay AS stdmaster_sdm_allowancepay,
		paytype_b.pyt_pretax AS allowance_pyt_pretax,
		paytype_b.pyt_minus AS allowance_pyt_minus,
		stdmaster.sdm_deddays AS stdmaster_sdm_deddays,
		stdmaster.sdm_dedweeks AS stdmaster_sdm_dedweeks,
		stdmaster.sdm_dedmonths AS stdmaster_sdm_dedmonths,
		stdmaster.sdm_dedround AS stdmaster_sdm_dedround,
		standingdeduction.std_reductionrate AS standingdeduction_std_reductionrate,
		stdmaster.sdm_reductionterm AS stdmaster_sdm_reductionterm,
		stdmaster.sdm_minusbalance AS stdmaster_sdm_minusbalance,
		stdmaster.sdm_miletype AS stdmaster_sdm_miletype,
		IsNull( stdmaster.pyt_group, 'UNK') AS pyt_group, 
		stdmaster.sdm_cap AS stdmaster_sdm_cap,
		stdmaster.sdm_ratetable AS stdmaster_sdm_ratetable,
		std_gst AS std_gst,
		std_refnumtype AS std_refnumtype,
		std_refnum AS std_refnum,
		stdmaster.sth_abbr AS stdmaster_sth_abbr,
		IsNull(sth_priority, 999) AS sth_priority,
		IsNull(sdm_sth_priority, 999) AS sdm_sth_priority,
		stdmaster.sdm_itemcode AS stdmaster_sdm_itemcode,
		std_RemitToVendorID AS std_remittovendorid,
		sdm_Garnishment AS sdm_garnishment,
		sdm_CapPercent AS sdm_cappercent,
		sdm_AdjustWithNegativePay AS sdm_adjustwithnegativepay,
		stdmaster.pyt_itemcodenontax AS stdmaster_pyt_itemcodenontax,
		paytype_c.pyt_pretax AS paytype_pyt_pretaxnontax,
		paytype_c.pyt_minus AS paytype_pyt_minusnontax,
		paytype_a.pyt_garnishmentclassification AS paytype_pyt_garnishmentclassification
FROM @deductionlist dl
join standingdeduction on dl.std_number = standingdeduction.std_number
join stdmaster on stdmaster.sdm_itemcode = standingdeduction.sdm_itemcode
left join stdhierarchy on stdmaster.sth_abbr = stdhierarchy.sth_abbr
left outer join paytype paytype_a on  stdmaster.pyt_itemcode = paytype_a.pyt_itemcode
left outer join paytype paytype_b on stdmaster.sdm_allowancepay = paytype_b.pyt_itemcode		
left outer join paytype paytype_c on stdmaster.pyt_itemcodenontax = paytype_c.pyt_itemcode		



GO
GRANT EXECUTE ON  [dbo].[d_pay_collectdeductions_sp] TO [public]
GO
