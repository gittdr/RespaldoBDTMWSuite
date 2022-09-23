SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[D_ordorigindest_SP](@ordhdrnumber	INT,
				 @movnumber INT = 0)
AS
/**
 * NAME:
 * D_ordorigindest_S
 * 
 * TYPE:
 * StoredProcedure
 * 
 * DESCRIPTION:
 * Provide a return set the origing ans destination of an order or a movement for paperwork
 * 
 * RETURN:
 * none
 * 
 * RESULT SETS:
 * Refer to the final select statement for the return set. 
 *
 * PARAMETERS:
 * 01 @ordhdrnumber   	int	ordhdrnumber (if passed movnumber will be zero)
 * 02 @movnumber  	int	mov_number (if passed orhdrnumber iwll be zero
 * 
 * REFERENCES: 
 *  NONE
 *
 * REVISION HISTORY:
 * 12/28/06 PTS 34565 DPETE created
 **/
if @movnumber > 0
 BEGIN
  SELECT orderheaderstart.ord_startdate,  
         orderheaderend.ord_completiondate,
	orderheaderstart.ord_originpoint,
	orderheaderend.ord_destpoint,   
         company_a.cmp_name origincompanyname,  
         company_b.cmp_name destcompanyname,  
         city_a.cty_nmstct originctynmstct,  
         city_b.cty_nmstct destctynmstct          
  FROM /* dummy table of one row with origin info */
       (select ord_startdate,
        ord_origincity,
        ord_originpoint,
         dummylink = 0
         from orderheader        
        where ord_hdrnumber = (select ord_hdrnumber from stops
         where mov_number = @movnumber and stp_mfh_sequence = (select min(stp_mfh_sequence)
         from stops s2 where s2.mov_number = @movnumber and ord_hdrnumber > 0))) orderheaderstart
        /* dummy table with dest information joined to one above on fake key */
      join (select ord_completiondate,
           ord_destcity,
           ord_destpoint,
           dummylink = 0
         from orderheader where ord_hdrnumber = (select ord_hdrnumber from stops
         where mov_number = @movnumber and stp_mfh_sequence = (select max(stp_mfh_sequence)
         from stops s2 where s2.mov_number = @movnumber and ord_hdrnumber > 0))) orderheaderend
         on orderheaderstart.dummylink =  orderheaderend.dummylink
      left outer join city city_a on orderheaderstart.ord_origincity = city_a.cty_code
      left outer join city city_b on orderheaderend.ord_destcity = city_b.cty_code
      left outer join company company_a on orderheaderstart.ord_originpoint = company_a.cmp_id
      left outer join company company_b on orderheaderend.ord_destpoint = company_b.cmp_id
  END  
else

 BEGIN
  SELECT orderheader.ord_startdate,  
         orderheader.ord_completiondate,
	orderheader.ord_originpoint,
	orderheader.ord_destpoint,
        company_a.cmp_name origincompanyname,
         company_b.cmp_name destcompanyname,
         city_a.cty_nmstct originctynmstct,
         city_b.cty_nmstct destctynmstct  
  FROM orderheader
   left outer join city city_a on orderheader.ord_origincity = city_a.cty_code
   left outer join city city_b on orderheader.ord_destcity = city_b.cty_code
   left outer join company company_a on orderheader.ord_originpoint = company_a.cmp_id
   left outer join company company_b on orderheader.ord_destpoint = company_b.cmp_id
  WHERE orderheader.ord_hdrnumber = @ordhdrnumber  
 END 
GO
GRANT EXECUTE ON  [dbo].[D_ordorigindest_SP] TO [public]
GO
