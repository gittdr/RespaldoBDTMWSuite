SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[GetStpOrdMileageForOrderCustom](@p_ordhdrnumber int,
					 @p_revtype  varchar(6))
AS
/**
 *
 * NAME:
 * dbo.GetStpOrdMileageForOrderCustom
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure is probably of no use to anyone but KAG
 * It returns the sum of the stp_ord_mileage for an order where the RevType1 value passed
 * has a lebelfile extrastring1 value of 'BillActualMiles'
 * called by nvo_tariff_engine2 to replace standard miles on tariff table with
 * this amount (cusotmer did not want to look up miles in invoicing because of volume
 *  of calls and performance
 *
 * RETURNS:
 * the sum of the ord mielage or -1 (indicates RevType did not specify using stpmileage)
 *
 * RESULT SETS:
 * n/a
 *
 * Sample call
declare @mil int

exec @mil = GetStpOrdMileageForOrderCustom 7002,'tmw'

select @mil

 * PARAMETERS:
 * 001 - @p_ordhdrnumber int
 * 002 - @p_RevtypeValue
 *
 *
 * REVISION HISTORY:
 * 7/20/10 DPETE created for PTS52712
 *
 **/
DECLARE	@v_miles int
select @v_miles = 0

If @p_ordhdrnumber = 0
	select @v_miles = 0
else
  BEGIN 
   If not exists (select 1 from labelfile where labeldefinition = 'RevType1'
     and abbr = @p_revtype and upper(label_extrastring1) = 'BILLACTUALMILES')
       select @v_miles = -1
   else
    select @v_miles = sum(isnull(stp_ord_mileage,0))
    from stops where ord_hdrnumber > 0
    and ord_hdrnumber = @p_ordhdrnumber
  END
RETURN @v_miles

GO
GRANT EXECUTE ON  [dbo].[GetStpOrdMileageForOrderCustom] TO [public]
GO
