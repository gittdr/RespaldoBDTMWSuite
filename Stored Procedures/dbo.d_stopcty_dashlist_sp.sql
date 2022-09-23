SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_stopcty_dashlist_sp] (@p_ordhdrnumber int)
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
 * 11/13/08 DPETE PTS 45138 state is being returned in mixed case, want upper
 *
 **/

Create table #stopcities 
(
  stp_number INT,
  cty_name VARCHAR(18) NULL,
  cty_state VARCHAR(6) NULL,
  stp_ident int IDENTITY
)

--SET IDENTITY_INSERT #stopcities ON

Declare @v_next int, @v_citystop VARCHAR(500), @v_recordcount INT

SELECT @v_citystop = ''

Insert Into #stopcities (stp_number, cty_name, cty_state)    
SELECT stops.stp_number, city.cty_name, city.cty_state 
FROM stops, city
WHERE stops.ord_hdrnumber = @p_ordhdrnumber
AND stops.stp_city = cty_code
ORDER BY stp_sequence

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
       select @v_citystop = @v_citystop +
                        IsNull(cty_name,'') + ', ' + isnull(cty_state,'') + 
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
       SELECT @v_citystop = @v_citystop +
                        IsNull(cty_name,'') + ', ' + isnull(cty_state,'')
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

DROP TABLE #stopcities

GO
GRANT EXECUTE ON  [dbo].[d_stopcty_dashlist_sp] TO [public]
GO
