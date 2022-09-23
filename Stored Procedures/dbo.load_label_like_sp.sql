SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[load_label_like_sp] @name varchar(100)  as
/**
 * 
 * NAME:
 * dbo.load_label_like_sp
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
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 07/21/2005.02 PTS 33843 - DPETE used for 'Units" in lots of datawindows where they only want rating units
 *      like WeightUnits, VOlumeUnits, etc.  As developers add other %Units labelfile entries this gets gunked up
 *      this treats the @name = 'Units' in a specail way to limit to rating units if GI UseALLUnitsInDDW is set N
 *
 **/
 declare @allunits char(1)

 /* in case we have a customer problem with showing all units - secret GI setting limits like Units to rating units */
 Select @allunits = Upper(gi_string1) from generalinfo where gi_name = 'UseALLUnitsInDDW'
 Select @allunits = Case isnull(@allunits,'Y') when 'N' then 'N' else 'Y' end

If Upper(@name) = 'UNITS' and @allunits = 'N' 
  SELECT labelfile.name, 
  labelfile.abbr,   
  labelfile.code  
  FROM labelfile  
  WHERE labelfile.labeldefinition in('WeightUnits','VolumeUnits','FlatUnits','DistanceUnits','CountUnits','TimeUnits','RevUnits') and
	IsNull(retired, 'N') <> 'Y'
  ORDER BY labelfile.code ASC

ELSE

  SELECT labelfile.name,   
  labelfile.abbr,   
  labelfile.code ,labeldefinition
  FROM labelfile  
  WHERE labelfile.labeldefinition like '%' + @name and
	IsNull(retired, 'N') <> 'Y'
  ORDER BY labelfile.code ASC

GO
GRANT EXECUTE ON  [dbo].[load_label_like_sp] TO [public]
GO
