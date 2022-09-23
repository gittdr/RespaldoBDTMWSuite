SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[d_inv_format106_subreport_stops_sp] (@p_ordhdrnumber int)
AS  
/**
 * 
 * NAME:
 * dbo.d_stopcty_dashlist_sp
 *
 * TYPE:
 * [StoredProcedure)
 *
 * DESCRIPTION:
 * This procedure returns a single row with a dash separated list of all billable stop cities for the order 
 * that is passed in.
 *
 *  Example: exec d_stopcty_dashlist_sp 790
 *             Returns 'Baltimore,MD-Baltimore,MD-Lansing,MI'
 *  In the example above we have 3 stops that are billable 2 in Baltimore MD and 1 in Lansing MI.
 * 
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * ordercitystate varchar(500) a dash separated list of all city, state abbr pairs on the order.
 *
 * PARAMETERS:
 * 001 - @p_ordhdrnumber int
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * 
 * REVISION HISTORY:
 * 07/26/2006.01 ? PTS33638 - Phil Bidinger ? Created for Invoice Format 97 (Jack B. Kelley)
 *
 **/
Create table #stopcities 
(
  stp_ident int IDENTITY, 
  stp_number INT,
  stp_type VARCHAR(6),
  stp_companyid VARCHAR(18) NULL,
  Stp_companyname VARCHAR(100) NULL,
  cty_name VARCHAR(18) NULL,
  cty_state VARCHAR(6) NULL,
  total_pieces decimal (10,2),
  total_weight decimal(10,2)
)

--SET IDENTITY_INSERT #stopcities ON
Declare @v_next int, @v_citystop VARCHAR(500), @v_recordcount INT
SELECT @v_citystop = ''
Insert Into #stopcities (stp_number, stp_type, stp_companyid , stp_companyname, cty_name, cty_state,total_pieces,total_weight)    
SELECT stops.stp_number, stops.stp_type, stops.cmp_id, company.cmp_name, city.cty_name, city.cty_state,
	(select isnull(sum(isnull(fgt_count,0)),0) from freightdetail f
	where f.stp_number = stops.stp_number AND
		stops.stp_type = 'DRP'),
	(select isnull(sum(isnull(fgt_weight,0)),0) from freightdetail f
	where f.stp_number = stops.stp_number AND
		stops.stp_type = 'DRP')
FROM stops, city, company
WHERE stops.ord_hdrnumber = @p_ordhdrnumber
AND stops.stp_city = cty_code
and stops.Cmp_id = company.cmp_id
ORDER BY stp_sequence
/*
select * from stops
Select @v_next = Min(stp_ident) From #stopcities     
Select @v_next = IsNull(@v_next,0)
SELECT @v_recordcount = COUNT(stp_ident) FROM #stopcities
    
While @v_next > 0
 BEGIN
   -- Decide if we are on an even or odd run.  This isn't currently relevant but could be if the situation should
   -- change.
   IF (ABS(@v_next) % 2 = 1)
   --odd
   BEGIN
       select @v_citystop = @v_citystop + isnull (Stp_companyname, '')+
                        IsNull(cty_name,'') + ', ' + (UPPER(SUBSTRING(ISNULL(cty_state, ' '), 1, 1)) + LOWER(SUBSTRING(ISNULL(cty_state, ' '), 2, LEN(cty_state)))) + 
                        + (CASE
       WHEN @v_recordcount <> @v_next 
       THEN ' - ' 
       ELSE ' '
     END)
       from #stopcities  
       where stp_ident = @v_next
   END
   ELSE
   BEGIN
   --even
       SELECT @v_citystop = @v_citystop + isnull (Stp_companyname, '')+
                        IsNull(cty_name,'') + ', ' + (UPPER(SUBSTRING(ISNULL(cty_state, ' '), 1, 1)) + LOWER(SUBSTRING(ISNULL(cty_state, ' '), 2, LEN(cty_state)))) 
                        + (CASE
       WHEN @v_recordcount <> @v_next 
       THEN ' - ' 
       ELSE ' '
     END)
       FROM #stopcities  
       WHERE stp_ident = @v_next
   END
   select  @v_next = min(stp_ident) from #stopcities where stp_ident > @v_next
 END    
SELECT ordercitystate = @v_citystop
*/
select 
Stp_companyname,
stp_type,
cty_name, 
cty_state,
total_pieces,
total_weight
from  #stopcities

DROP TABLE #stopcities
GO
GRANT EXECUTE ON  [dbo].[d_inv_format106_subreport_stops_sp] TO [public]
GO
