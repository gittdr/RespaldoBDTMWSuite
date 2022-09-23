SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_next_asgn_sp] (@asgn_id  varchar(13), @asgn_type varchar(6))
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
-- PTS 19859 -- BL -- 9/16/03
-- NEW PROC (was SQL within the 'd_next_asgn' datawindow)
 * 10/31/2007.01 ? PTS40115 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

--PTS 62031 NLOKE changes from Mindy to enhance performance
Set nocount on
set transaction isolation level read uncommitted
--end 62031
-- Create temp table
CREATE TABLE #next_asgn_temp(
 	mov_number		int null,   
        ord_hdrnumber		int null,   
        cmp_id			varchar(8) null,   
        cmp_name		varchar(100) null,   
        lgh_startdate		datetime null,   
        lgh_number		int null,   
        ord_number		varchar(12) null,   
        ord_fromorder		varchar(12) null,   
        origin_cty_nmstct	varchar(30) null,   
        dest_cty_nmstct		varchar(30) null,   
        schedule_id		int null,
	lgh_startcity		int null)  

-- Get the next 'Dispatched' or 'Planned' trip assignments for given resource
INSERT INTO #next_asgn_temp
 SELECT DISTINCT legheader.mov_number,   
         legheader.ord_hdrnumber,   
         company.cmp_id,   
         company.cmp_name,   
         legheader.lgh_startdate,   
         legheader.lgh_number,   
         orderheader.ord_number,   
         orderheader.ord_fromorder,   
         dbo.company.cty_nmstct,   
         city.cty_nmstct,   
         0 schedule_id,
	 legheader.lgh_startcity  
    FROM legheader LEFT OUTER JOIN orderheader on legheader.ord_hdrnumber = orderheader.ord_hdrnumber,   
         city,   
         company,   
         assetassignment             
   WHERE ( legheader.lgh_number = assetassignment.lgh_number ) and  
         ( legheader.cmp_id_start = company.cmp_id ) and  
         ( legheader.lgh_endcity = city.cty_code ) and  
         ( ( assetassignment.asgn_id = @asgn_id) AND  
         ( assetassignment.asgn_type = @asgn_type) AND  
         ( assetassignment.asgn_status in ('DSP', 'PLN') ) )    

-- Update start_city from Legheader where start_company is 'UNKNOWN'
UPDATE 	#next_asgn_temp 
SET	#next_asgn_temp.origin_cty_nmstct = city.cty_nmstct
FROM	#next_asgn_temp, city 
WHERE	#next_asgn_temp.lgh_startcity = city.cty_code
AND	#next_asgn_temp.cmp_id = 'UNKNOWN' 

-- Get result set
SELECT * 
FROM #next_asgn_temp

-- Drop temp table
DROP TABLE #next_asgn_temp


GO
GRANT EXECUTE ON  [dbo].[d_next_asgn_sp] TO [public]
GO
