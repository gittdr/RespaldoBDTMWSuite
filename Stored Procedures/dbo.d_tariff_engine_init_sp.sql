SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_tariff_engine_init_sp] 
		(@cmdcode varchar(8),
		@orderedby varchar(8),
		@trailer varchar(13),
		@tractor varchar(8),
		@originpoint varchar(8),
		@origincity int,
		@destpoint varchar(8),
		@destcity int,
		@trailer2 varchar(13),
		@chassis varchar(13),
		@chassis2 varchar(13),
		@dolly varchar(13),
		@dolly2 varchar(13),
		@trailer3 varchar(13),
		@trailer4 varchar(13),
		@driver varchar(8)		-- 62954
		)

AS

--	LOR	PTS# 33990	add trc, trl terminal
--	LOR	PTS# 38859	add trailer2 to get axles
--  NQIOA PTS# 62954 get new granfather dates for driver and tractor

DECLARE 
@cmd_class varchar(8),
@cmp_othertype1 varchar(6) ,
@cmp_othertype2 varchar(6) ,
@trl_type1 varchar(6) ,
@trl_type2 varchar(6) ,
@trl_type3 varchar(6) ,
@trl_type4 varchar(6) ,
@trc_type1 varchar(6) ,
@trc_type2 varchar(6) ,
@trc_type3 varchar(6) ,
@trc_type4 varchar(6) ,
@trl_axles tinyint ,
@trc_axles tinyint ,
@originzip char(3) ,
@originzipfull char(10) ,
@originstate char(6) ,
@origincounty varchar(3) ,
@destzip char(3) ,
@destzipfull char(10) ,
@deststate char(6) ,
@destcounty varchar(3),
@trl_terminal	varchar(6),
@trc_terminal	varchar(6),
@trl2_type1 varchar(6) ,
@trl2_type2 varchar(6) ,
@trl2_type3 varchar(6) ,
@trl2_type4 varchar(6),
@trl2_axles tinyint,
@chassis_axles tinyint,
@chassis2_axles tinyint,
@dolly_axles tinyint,
@dolly2_axles tinyint,
@trailer3_axles tinyint,
@trailer4_axles tinyint,
@driver_grandfatherdate datetime,	-- 62954
@tractor_grandfatherdate datetime	-- 62954

-- Get the commodity class
SELECT @cmd_class = cmd_class
FROM commodity
WHERE cmd_code = @cmdcode

-- Get the other company types
SELECT @cmp_othertype1 = cmp_othertype1,
       @cmp_othertype2 = cmp_othertype2
FROM company
WHERE cmp_id = @orderedby

-- Get the trailer types and number of axles
SELECT @trl_type1 = trl_type1,
       @trl_type2 = trl_type2,
       @trl_type3 = trl_type3,
       @trl_type4 = trl_type4,
       @trl_axles = trl_axles,
		@trl_terminal = trl_terminal
FROM trailerprofile
WHERE trl_id = @trailer

-- Get the trailer types and number of axles
SELECT @trl2_type1 = trl_type1,
       @trl2_type2 = trl_type2,
       @trl2_type3 = trl_type3,
       @trl2_type4 = trl_type4,
       @trl2_axles = trl_axles
FROM trailerprofile
WHERE trl_id = @trailer2

--JLB PTS 51070 get the axle counts for new trailing equipment
if @chassis <> 'UNKNOWN'
	SELECT	@chassis_axles = trl_axles
	FROM    trailerprofile
	WHERE   trl_id = @chassis
else
	select @chassis_axles = 0
	
if @chassis2 <> 'UNKNOWN'
	SELECT	@chassis2_axles = trl_axles
	FROM    trailerprofile
	WHERE   trl_id = @chassis2
else
	select @chassis2_axles = 0
	
if @dolly <> 'UNKNOWN'
	SELECT	@dolly_axles = trl_axles
	FROM    trailerprofile
	WHERE   trl_id = @dolly
else
	select @dolly_axles = 0

if @dolly2 <> 'UNKNOWN'
	SELECT	@dolly2_axles = trl_axles
	FROM    trailerprofile
	WHERE   trl_id = @dolly2
else
	select @dolly2_axles = 0

if @trailer3 <> 'UNKNOWN'
	SELECT	@trailer3_axles = trl_axles
	FROM    trailerprofile
	WHERE   trl_id = @trailer3
else
	select @trailer3_axles = 0
	
if @trailer4 <> 'UNKNOWN'
	SELECT	@trailer4_axles = trl_axles
	FROM    trailerprofile
	WHERE   trl_id = @trailer4
else
	select @trailer4_axles = 0
--end 51070	

-- granfather dates should be null unless a date is specified 62954
SELECT @driver_grandfatherdate = mpp_grandfather_date
from manpowerprofile
where mpp_id = @driver 

-- Get the number of tractor axles
SELECT @trc_axles = trc_axles,
	@trc_type1 = trc_type1,
	@trc_type2 = trc_type2,
	@trc_type3 = trc_type3,
	@trc_type4 = trc_type4,
	@trc_terminal = trc_terminal,
    @tractor_grandfatherdate = trc_grandfather_date		-- 62954
FROM tractorprofile
WHERE trc_number = @tractor

--JD 12/21/99 #6929 get the zip from the city if the company is unknown
-- Get the 1st 3 digits of the zip code for the origin point company or city 
IF @originpoint <> 'UNKNOWN'
	SELECT @originzip = SUBSTRING(cmp_zip, 1, 3)
		 , @originzipfull = cmp_zip
	FROM company
	WHERE cmp_id = @originpoint
ELSE
	SELECT @originzip = SUBSTRING(cty_zip, 1, 3)
		 , @originzipfull = cty_zip
	FROM city
	WHERE cty_code = @origincity

-- Get the 1st 3 digits of the zip code for the destination point company or city
IF @destpoint <> 'UNKNOWN'
	SELECT @destzip = SUBSTRING(cmp_zip, 1, 3)
	 	 , @destzipfull = cmp_zip
	FROM company
	WHERE cmp_id = @destpoint
ELSE
	SELECT @destzip = SUBSTRING(cty_zip, 1, 3)
		 , @destzipfull = cty_zip
	FROM city
	WHERE cty_code = @destcity


-- Get the state and county for the origin point city
SELECT @originstate = cty_state,
       @origincounty = cty_county
FROM city
WHERE cty_code = @origincity

-- Get the state and county for the destination point city
SELECT @deststate = cty_state,
       @destcounty = cty_county
FROM city
WHERE cty_code = @destcity

-- Fix any nulls
SELECT cmd_class = IsNull(@cmd_class, ''),
       cmp_othertype1 = IsNull(@cmp_othertype1, ''),
       cmp_othertype2 = IsNull(@cmp_othertype2, ''),
       trl_type1 = IsNull(@trl_type1, ''),
       trl_type2 = IsNull(@trl_type2, ''),
       trl_type3 = IsNull(@trl_type3, ''),
       trl_type4 = IsNull(@trl_type4, ''),
       trl_axles = IsNull(@trl_axles, 0),
       trc_axles = IsNull(@trc_axles, 0),
       originzip = IsNull(@originzip, ''),
       originstate = IsNull(@originstate, ''),
       origincounty = IsNull(@origincounty, ''),
       destzip = IsNull(@destzip, ''),
       deststate = IsNull(@deststate, ''),
       destcounty = IsNull(@destcounty, ''),
	trc_type1 = ISNULL(@trc_type1,''),
	trc_type2 = ISNULL(@trc_type2,''),
	trc_type3 = ISNULL(@trc_type3,''),
	trc_type4 = ISNULL(@trc_type4,''),
	originzipfull = ISNULL(@originzipfull, ''),
	destzipfull = ISNULL(@destzipfull, ''),
	trc_terminal = ISNULL(@trc_terminal,'UNK'),
	trl_terminal = ISNULL(@trl_terminal,'UNK'),
       trl2_type1 = IsNull(@trl2_type1, ''),
       trl2_type2 = IsNull(@trl2_type2, ''),
       trl2_type3 = IsNull(@trl2_type3, ''),
       trl2_type4 = IsNull(@trl2_type4, ''),
       trl2_axles = IsNull(@trl2_axles, 0),
       chassis_axles = IsNull(@chassis_axles, 0),
       chassis2_axles = IsNull(@chassis2_axles, 0),
       dolly_axles = IsNull(@dolly_axles, 0),
       dolly2_axles = IsNull(@dolly2_axles, 0),
       trailer3_axles = IsNull(@trailer3_axles, 0),
       trailer4_axles = IsNull(@trailer4_axles, 0),
       @driver_grandfatherdate ,	-- 62954 null means no date specified
       @tractor_grandfatherdate		-- 62954 null means no date specified
GO
GRANT EXECUTE ON  [dbo].[d_tariff_engine_init_sp] TO [public]
GO
