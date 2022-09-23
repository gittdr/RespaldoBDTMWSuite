SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create PROC [dbo].[d_loadholidayrule_sp] @rule varchar(12) , @number int AS
/**
 * 
 * NAME:
 * dbo.d_loadholidayrule_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Instant best match for holiday rule hrule_code
 *
 * RETURNS:
 * no return code
 *
 * RESULT SETS: 
 *  NONE
 *
 * PARAMETERS:
 * 001 -  @rule varchar(12) 
 * 002 -  @number int
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 3/23/07 DPETE PTS35747 DPETE  - Created for new taBLE KEY

 */

declare @match_rows int

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

	if exists(SELECT hrule_code FROM holidayrule WHERE hrule_code LIKE @rule + '%' )
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0

if @match_rows > 0  		
		SELECT	hrule_code
            ,name =isnull(hrule_name,'')
            ,hrule_id
--            ,hrule_holiday_country
            ,hrule_holiday = isnull(hrule_holiday,'UNK')
            ,hrule_holiday_group = isnull(hrule_holiday_group,'UNK')			
			FROM holidayrule 
			WHERE hrule_code LIKE @rule + '%' 
			ORDER BY hrule_code

else 
	
	SELECT	hrule_code
            ,isnull(hrule_name,'')
            ,hrule_id
--            ,hrule_holiday_country
            ,hrule_holiday  = isnull(hrule_holiday,'UNK')
            ,hrule_holiday_group = isnull(hrule_holiday_group,'UNK')				
			FROM holidayrule 
			WHERE hrule_code = 'UNKNOWN'
	

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadholidayrule_sp] TO [public]
GO
