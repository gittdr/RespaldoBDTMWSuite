SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_holidaypay_assets_sp]    (@Types varchar(60),
					@Status varchar(6),
					@LoPayDate datetime,
					@HiPayDate datetime,
					@Company char(6),
					@Fleet char(6),
					@Division char(6),
					@Terminal char(6),
					@DrvType1 char(6),
					@DrvType2 char(6),
					@DrvType3 char(6),
					@DrvType4 char(6),
					@TrcType1 char(6),
					@TrcType2 char(6),
					@TrcType3 char(6),
					@TrcType4 char(6),
					@TrlType1 char(6),
					@TrlType2 char(6),
					@TrlType3 char(6),
					@TrlType4 char(6),
					@Driver char(8),
					@Tractor char(8),
					@Trailer char(13),
					@account_type char(1),
					@Carrier char(8),
					@CarType1 char(6),
					@CarType2 char(6),
					@CarType3 char(6),
					@CarType4 char(6))  AS 

/**
 *
 * NAME:
 * dbo.d_holidaypay_assets_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used to retrieve assets for holiday pay
 *
 * RETURNS:
 *
 * RESULT SETS:
 * asgn_type	Type
 * asgn_id		ID
 * resourcename	Name
 * 1			Constant 1 to allow de-selection
 *
 * PARAMETERS:
 * @Types varchar(60),
 * @Status varchar(6),
 * @LoPayDate datetime,
 * @HiPayDate datetime,
 * @Company char(6),
 * @Fleet char(6),
 * @Division char(6),
 * @Terminal char(6),
 * @DrvType1 char(6),
 * @DrvType2 char(6),
 * @DrvType3 char(6),
 * @DrvType4 char(6),
 * @TrcType1 char(6),
 * @TrcType2 char(6),
 * @TrcType3 char(6),
 * @TrcType4 char(6),
 * @TrlType1 char(6),
 * @TrlType2 char(6),
 * @TrlType3 char(6),
 * @TrlType4 char(6),
 * @Driver char(8),
 * @Tractor char(8),
 * @Trailer char(13),
 * @account_type char(1),
 * @Carrier char(8),
 * @CarType1 char(6),
 * @CarType2 char(6),
 * @CarType3 char(6),
 * @CarType4 char(6))
 *
 * REVISION HISTORY:
 * vjh	PTS# 44302	Added column to result set for use as a selection checkbox.
 **/

declare 
	@AcctType1 	char(1) , 
	@AcctType2 	char(1) ,
	@drivers_yes 	int,
	@tractors_yes 	int,
	@trailer_yes 	int,
	@carrier_yes	int,
	@type		varchar(6),
	@id		char(13),
	@paydate 	datetime,
	@resourcename varchar(100)

SELECT @paydate = dateadd ( hour, -23, @HiPayDate )
SELECT @paydate = dateadd ( minute, -59, @paydate )

/* SET ACCOUNT TYPES */
if @account_type = 'X' 
	begin /* treat 'Any' as either A or P */
	SELECT @AcctType1 = 'A' 
	SELECT @AcctType2 = 'P' 
	end 
else if @account_type = 'A' 
	begin 
	SELECT @AcctType1 = 'A' 
	SELECT @AcctType2 = 'A' 
	end 
else if @account_type = 'P' 
	begin 
	SELECT @AcctType1 = 'P' 
	SELECT @AcctType2 = 'P' 
	end 
else 
	begin /* treat 'none' as invalid */
	SELECT @AcctType1 = '.' 
	SELECT @AcctType2 = '.' 
	end 

/* CREATE TEMP TABLE */
SELECT	pyh_pyhnumber, 
	asgn_type, 
	asgn_id, 
	@resourcename resourcename,
	pyh_paystatus , 
	pyh_payperiod , 
	pyh_totalcomp , 
	pyh_totaldeduct , 
	pyh_totalreimbrs 
INTO #temp
FROM payheader
WHERE 1 = 2


select @drivers_yes = charindex('DRV', @Types)
select @tractors_yes = charindex('TRC', @Types)
select @trailer_yes = charindex('TRL', @Types)
select @carrier_yes = charindex('CAR', @Types)

IF (@drivers_yes = 0) AND (@tractors_yes = 0) AND (@trailer_yes = 0) AND (@carrier_yes = 0)
	begin
	SELECT asgn_type,asgn_id,resourcename FROM #temp
	return
	end

/* GENERATE ASSET LISTS FOR DRIVER */

if (@drivers_yes > 0)  
begin
	insert into #temp
	SELECT 	999,  
		'DRV', 
		mpp_id, 
		mpp_lastname +',' + mpp_firstname,
		'-' , 
		@HiPayDate,
		0.0000, 
		0.0000, 
		0.0000
	FROM manpowerprofile
	WHERE ( mpp_status <> 'OUT' OR mpp_terminationdt > dateadd ( day, -60, @HiPayDate ) ) AND 
		( @Driver in ( 'UNKNOWN' , mpp_id ) ) AND 
		( @Company in ( 'UNK' , mpp_company ) ) AND 
		( @Fleet in ( 'UNK' , mpp_fleet ) ) AND 
		( @Division in ( 'UNK' , mpp_division ) ) AND 
		( @Terminal in ( 'UNK' , mpp_terminal ) ) AND 
		( @DrvType1 in ( 'UNK' , mpp_type1 ) ) AND 
		( @DrvType2 in ( 'UNK' , mpp_type2 ) ) AND 
		( @DrvType3 in ( 'UNK' , mpp_type3 ) ) AND 
		( @DrvType4 in ( 'UNK' , mpp_type4 ) ) AND 
		( mpp_actg_type in ( @AcctType1 , @AcctType2 ) ) 
end

/* GENERATE ASSET LISTS FOR TRACTOR */


if (@tractors_yes > 0)  
begin
	insert into #temp
	SELECT 	-1,  
		'TRC', 
		trc_number,
		trc_number, 
		'-' , 
		@HiPayDate,
		0.0000, 
		0.0000, 
		0.0000
	FROM tractorprofile 
	WHERE ( trc_status <> 'OUT' OR trc_retiredate > dateadd ( day, -60, @HiPayDate ) ) AND 
		( @Tractor in ( 'UNKNOWN' , trc_number ) ) AND 
		( @Company in ( 'UNK' , trc_company ) ) AND 
		( @Fleet in ( 'UNK' , trc_fleet ) ) AND 
		( @Division in ( 'UNK' , trc_division ) ) AND 
		( @Terminal in ( 'UNK' , trc_terminal ) ) AND 
		( @TrcType1 in ( 'UNK' , trc_type1 ) ) AND 
		( @TrcType2 in ( 'UNK' , trc_type2 ) ) AND 
		( @TrcType3 in ( 'UNK' , trc_type3 ) ) AND 
		( @TrcType4 in ( 'UNK' , trc_type4 ) ) AND 
		( trc_actg_type in ( @AcctType1 , @AcctType2 ) )  
end
/* GENERATE ASSET LISTS FOR TRAILER */
if (@trailer_yes > 0)  
begin
	insert into #temp
	SELECT 	-1,  
		'TRL', 
		trl_id, 
		trl_id,
		'-' , 
		@HiPayDate,
		0.0000, 
		0.0000, 
		0.0000
	FROM trailerprofile 
	WHERE ( trl_status <> 'OUT' ) AND 
		( @Trailer in ( 'UNKNOWN' , trl_number ) ) AND 
		( @Company in ( 'UNK' , trl_company ) ) AND 
		( @Fleet in ( 'UNK' , trl_fleet ) ) AND 
		( @Division in ( 'UNK' , trl_division ) ) AND 
		( @Terminal in ( 'UNK' , trl_terminal ) ) AND 
		( @TrlType1 in ( 'UNK' , trl_type1 ) ) AND 
		( @TrlType2 in ( 'UNK' , trl_type2 ) ) AND 
		( @TrlType3 in ( 'UNK' , trl_type3 ) ) AND 
		( @TrlType4 in ( 'UNK' , trl_type4 ) ) AND 
		( trl_actg_type in ( @AcctType1 , @AcctType2 ) )   
end

/* GENERATE ASSET LISTS FOR CARRIER */
if (@carrier_yes > 0)  
begin
	insert into #temp
	SELECT 	-1,  
		'CAR', 
		car_id, 
		car_name,
		'-' , 
		@HiPayDate,
		0.0000, 
		0.0000, 
		0.0000
	FROM carrier 
	WHERE ( car_status <> 'OUT' ) AND 
		( @Carrier in ('UNKNOWN', car_id ) ) AND 
		( @CarType1 in ( 'UNK' , car_type1 ) ) AND 
		( @CarType2 in ( 'UNK' , car_type2 ) ) AND 
		( @CarType3 in ( 'UNK' , car_type3 ) ) AND 
		( @CarType4 in ( 'UNK' , car_type4 ) ) AND 
		( car_actg_type in ( @AcctType1 , @AcctType2 ) ) 
end

/* FINAL SELECT TO RETRIEVE RETUEN SET */
select asgn_type,asgn_id ,resourcename, 1 from #temp
order by resourcename, asgn_type, asgn_id
return


GO
GRANT EXECUTE ON  [dbo].[d_holidaypay_assets_sp] TO [public]
GO
