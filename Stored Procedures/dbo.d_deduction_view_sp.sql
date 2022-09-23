SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/****** Object:  Stored Procedure dbo.d_deduction_view_sp    Script Date: 8/20/97 1:57:20 PM ******/
CREATE PROC [dbo].[d_deduction_view_sp] 
	@Status varchar(60), 
	@Types varchar(60), 
-- PTS 35071 -- BL (start)
--	@Codes varchar(1000), 
	@Codes varchar(2000), 
-- PTS 35071 -- BL (end)
	@LoIssueDate datetime, 
	@HiIssueDate datetime, 
	@LoCloseDate datetime, 
	@HiCloseDate datetime, 
	@Company char(6), 
	@Fleet char(6), 
	@Division char(6), 
	@Terminal char(6), 
	@Driver char(8), 
	@DrvType1 char(6), 
	@DrvType2 char(6), 
	@DrvType3 char(6), 
	@DrvType4 char(6), 
	@Tractor char(8), 
	@TrcType1 char(6), 
	@TrcType2 char(6), 
	@TrcType3 char(6), 
	@TrcType4 char(6), 
	@Trailer char(13), 
	@TrlType1 char(6), 
	@TrlType2 char(6), 
	@TrlType3 char(6), 
	@TrlType4 char(6),
	@acct_type char(1),
	@Carrier char(8),
	@CarType1 char(6), 
	@CarType2 char(6), 
	@CarType3 char(6), 
	@CarType4 char(6)

AS 

/*
*	PTS 46542 - DJM - Modified to add the 'Paid to Date' amount.
*/
SELECT @Status = ',' + LTRIM(RTRIM(ISNULL(@Status, ''))) + ','
SELECT @Codes = ',' + LTRIM(RTRIM(ISNULL(@Codes, ''))) + ','


CREATE TABLE #temp(type_id varchar(30)) 

if(charindex('DRV', @Types) > 0) 
	INSERT INTO #temp 
		SELECT 'DRV' + mpp_id type_id 
		FROM manpowerprofile 
		WHERE (@Driver in ('UNKNOWN', mpp_id)) AND 
			(@Company in ('UNK', mpp_company)) AND 
			(@Fleet in ('UNK', mpp_fleet)) AND 
			(@Division in ('UNK', mpp_division)) AND 
			(@Terminal in ('UNK', mpp_terminal)) AND 
			(@DrvType1 in ('UNK', mpp_type1)) AND 
			(@DrvType2 in ('UNK', mpp_type2)) AND 
			(@DrvType3 in ('UNK', mpp_type3)) AND 
			(@DrvType4 in ('UNK', mpp_type4)) and
			(@acct_type in ('X' , mpp_actg_type)) 					 

if(charindex('TRC', @Types) > 0) 
	INSERT INTO #temp 
		SELECT 'TRC' + trc_number type_id 
		FROM tractorprofile 
		WHERE (@Tractor in ('UNKNOWN', trc_number)) AND 
			(@Company in ('UNK', trc_company)) AND 
			(@Fleet in ('UNK', trc_fleet)) AND 
			(@Division in ('UNK', trc_division)) AND 
			(@Terminal in ('UNK', trc_terminal)) AND 
			(@TrcType1 in ('UNK', trc_type1)) AND 
			(@TrcType2 in ('UNK', trc_type2)) AND 
			(@TrcType3 in ('UNK', trc_type3)) AND 
			(@TrcType4 in ('UNK', trc_type4)) AND
			(@acct_type in ('X', trc_actg_type))

if(charindex('TRL', @Types) > 0) 
	INSERT INTO #temp 
		SELECT 'TRL' + trl_id type_id 
		FROM trailerprofile 
		WHERE (@Trailer in ('UNKNOWN', trl_id)) AND 
			(@Company in ('UNK', trl_company)) AND 
			(@Fleet in ('UNK', trl_fleet)) AND 
			(@Division in ('UNK', trl_division)) AND 
			(@Terminal in ('UNK', trl_terminal)) AND 
			(@TrlType1 in ('UNK', trl_type1)) AND 
			(@TrlType2 in ('UNK', trl_type2)) AND 
			(@TrlType3 in ('UNK', trl_type3)) AND 
			(@TrlType4 in ('UNK', trl_type4)) AND
			(@acct_type in ('X', trl_actg_type))
 
if(charindex('CAR', @Types) > 0) 
	INSERT INTO #temp 
		SELECT 'CAR' + car_id type_id 
		FROM carrier 
		WHERE (@Carrier in ('UNKNOWN', car_id)) AND 
			(@CarType1 in ('UNK', car_type1)) AND 
			(@CarType2 in ('UNK', car_type2)) AND 
			(@CarType3 in ('UNK', car_type3)) AND 
			(@CarType4 in ('UNK', car_type4)) AND
			(@acct_type in ('X', car_actg_type))

SELECT standingdeduction.std_number , 
	standingdeduction.asgn_id, 
	standingdeduction.asgn_type, 
	standingdeduction.sdm_itemcode, 
	standingdeduction.std_balance, 
	standingdeduction.std_status, 
	standingdeduction.std_deductionrate, 
	standingdeduction.std_reductionrate, 
	standingdeduction.std_description, 
	standingdeduction.std_startbalance, 
	standingdeduction.std_endbalance, 
	standingdeduction.std_issuedate, 
	standingdeduction.std_closedate, 
	standingdeduction.std_priority,
    standingdeduction.std_balance * (case when standingdeduction.std_startbalance = 0 and dbo.standingdeduction.std_endbalance = 0 then -1 
                                               when stdmaster.sdm_minusbalance = 'N' then 1 else -1 end) cabs_balance,   
    standingdeduction.std_startbalance - standingdeduction.std_endbalance cabs_issueamount,
	stdmaster.sdm_reductionterm,
	stdmaster.sdm_minusbalance
FROM standingdeduction join #temp on (standingdeduction.asgn_type + standingdeduction.asgn_id) = #temp.type_id
	join stdmaster on stdmaster.sdm_itemcode = standingdeduction.sdm_itemcode
WHERE (standingdeduction.std_issuedate between @LoIssueDate and @HiIssueDate) AND
		(standingdeduction.std_closedate between @LoCloseDate and @HiCloseDate) AND 
		(charindex(',''' + standingdeduction.std_status + ''',', @Status) > 0) AND 
		(charindex(',''' + standingdeduction.sdm_itemcode + ''',' , @Codes) > 0)
	

GO
GRANT EXECUTE ON  [dbo].[d_deduction_view_sp] TO [public]
GO
