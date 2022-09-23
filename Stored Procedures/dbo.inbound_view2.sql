SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[inbound_view2]
	@trctype1       varchar(254),
	@trctype2       varchar(254),
	@trctype3       varchar(254),
	@trctype4       varchar(254),
	@fleet          varchar(254),
	@division       varchar(254),
	@company        varchar(254),

	@terminal       varchar(254),
	@states         varchar(254),
	@cmp_id         varchar(254),
	@region1        varchar(254),
	@region2        varchar(254),
	@region3        varchar(254),
	@region4        varchar(254),
	@city           int,
	@hoursback      int,
	@hoursout       int,
	@days           int
AS
/**
 * 
 * NAME:
 * dbo.inbound_view2
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * PTS 3436 PG 1/8/98 Performance Enhancement added NOLOCK on expiration
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 *
 **/


DECLARE @int            smallint,
	@neardate       datetime

SELECT  @neardate = DateAdd(dy, @days, GetDate())

SELECT  trailerprofile.trl_id,
	company_a.cmp_id,
	company_a.cmp_name,
	city_a.cty_nmstct,
	trailerprofile.trl_avail_date,
	trailerprofile.trl_status,
	trailerprofile.trl_type1,       
	trailerprofile.trl_type2, 
	trailerprofile.trl_type3, 
	trailerprofile.trl_type4,       
	trailerprofile.trl_company, 
	trailerprofile.trl_fleet, 
	trailerprofile.trl_division,
	trailerprofile.trl_terminal,
	city_a.cty_state,
	city_a.cty_code,
	@int    cpril2,
	@int    cpril22,
	@int    cpril1,
	@int    cpril11,
	'F' filtflag 
INTO    #TT
FROM    city city_a, company company_a, trailerprofile, labelfile 
WHERE   ( labeldefinition = 'TrlStatus' AND abbr = trl_status ) AND
	( code < 200 ) AND ( trailerprofile.trl_avail_cmp_id = company_a.cmp_id ) and 
	( trailerprofile.trl_avail_city = city_a.cty_code ) AND 
	( @trctype1 like '%'+trailerprofile.trl_type1+'%' OR @trctype1 = '') AND
	( @trctype2 like '%'+trailerprofile.trl_type2+'%' OR @trctype2 = '') AND
	( @trctype3 like '%'+trailerprofile.trl_type3+'%' OR @trctype3 = '') AND
	( @trctype4 like '%'+trailerprofile.trl_type4+'%' OR @trctype4 = '') AND        
	( @fleet like '%'+trailerprofile.trl_fleet+'%' OR @fleet = '') AND 
	( @division like '%'+trailerprofile.trl_division+'%' OR @division = '') AND 
	( @company like '%'+trailerprofile.trl_company+'%' OR @company = '') AND        
	( @terminal like '%'+trailerprofile.trl_terminal+'%' OR @terminal = '') AND     
	( @states like '%'+city_a.cty_state+'%' OR @states = '') AND    
	( @cmp_id like '%'+trailerprofile.trl_avail_cmp_id+'%' OR @cmp_id = '') AND
	( @region1 = city_a.cty_region1 OR @region1 = 'UNK' ) AND
	( @region2 = city_a.cty_region2 OR @region2 = 'UNK' ) AND 
	( @region3 = city_a.cty_region3 OR @region3 = 'UNK' ) AND 
	( @region4 = city_a.cty_region4 OR @region4 = 'UNK' ) AND
	( @city = city_a.cty_code OR @city = 0 ) AND    
	( trailerprofile.trl_avail_date >= dateadd ( hour, -@hoursback, getdate() ) AND
	trailerprofile.trl_avail_date <= dateadd ( hour, @hoursout, getdate() ) )
NO_LOCK1:
UPDATE  #TT
SET     cpril2 = ( SELECT COUNT (*) 
		FROM expiration (NOLOCK)
		WHERE ( ( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'TRC' AND exp_id = '' ) OR 
		( exp_idtype = 'TRL' AND exp_id = #TT.trl_id ) OR 
		( exp_idtype = 'CAR' AND exp_id = '' )) AND
		exp_expirationdate <= GetDate() AND 
		exp_completed = 'N' AND
		exp_priority = '1' )
IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) GOTO NO_LOCK1
NO_LOCK2:
UPDATE  #TT
SET	cpril22 = ( SELECT COUNT (*) 
		FROM expiration (NOLOCK)
		WHERE ( ( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'TRC' AND exp_id = '' ) OR 
		( exp_idtype = 'TRL' AND exp_id = #TT.trl_id ) OR 
		( exp_idtype = 'CAR' AND exp_id = '' )) AND
		exp_expirationdate <= @neardate AND 
		exp_completed = 'N' AND
		exp_priority = '1' )
IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) GOTO NO_LOCK2
NO_LOCK3:
UPDATE  #TT
SET	cpril1 = ( SELECT COUNT (*) 
		FROM expiration (NOLOCK)
		WHERE ( ( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'TRC' AND exp_id = '' ) OR 
		( exp_idtype = 'TRL' AND exp_id = #TT.trl_id ) OR 
		( exp_idtype = 'CAR' AND exp_id = '' )) AND 
		exp_expirationdate <= GetDate() AND 
		exp_completed =  'N' AND
		exp_priority > '1' )
IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) GOTO NO_LOCK3
NO_LOCK4:
UPDATE  #TT
SET	cpril11 = ( SELECT COUNT (*) 
		FROM expiration (NOLOCK)
		WHERE ( ( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'DRV' AND exp_id = '' ) OR 
		( exp_idtype = 'TRC' AND exp_id = '' ) OR 
		( exp_idtype = 'TRL' AND exp_id = #TT.trl_id ) OR 
		( exp_idtype = 'CAR' AND exp_id = '' )) AND 
		exp_expirationdate <= @neardate AND 
		exp_completed =  'N' AND
		exp_priority > '1' )
IF (@@error = 605 OR @@error = 606 OR @@error = 624 OR @@error = 625) GOTO NO_LOCK4
GO
GRANT EXECUTE ON  [dbo].[inbound_view2] TO [public]
GO
