SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[copyorder_compvalidation_sp] ( @p_ordnumber VARCHAR(12),
						   @p_total_inactive INT OUTPUT)
			
AS

/**
 * NAME:
 * dbo.copyorder_compvalidation_sp
 * 
 * TYPE:
 * StoredProcedure
 * 
 * DESCRIPTION:
 * This procedure excepts an ord_number from the copy orders window.  It's function is to return the count
 * count of inactive companies on the order.  This will allow the window to reject copying of orders
 * that contain inactive companies.  Please note that this procedure is only used there as of its initial
 * release.
 * 
 * RETURN:
 * none.
 * 
 * RESULT SETS:
 * Refer to the Select list. 
 *
 * PARAMETERS:
 * 01 @p_ordnumber varchar(12) - Input for an ordernumber
 * 02 @p_total_inactive INT - Output for a count of our inactive companies.
 * 
 * REFERENCES: (called by and calling references only, don't include table/view/object references)
 * Calls001    ? NONE
 * CalledBy001 ? NONE
 *
 * REVISION HISTORY:
 *
 * 09/26/06 PTS 34244 - PRB - Initial version released.
 * 04/27/11 DPETE PTS55677 extend to verify that bill to ocmpany is still a bill to and 
 *    that all pickups are still shippers and all delivery companies are still active consignees
 **/

SET NOCOUNT ON

DECLARE
@v_inactive_ordcomp INT,
@v_inactive_billto INT,
--@v_inactive_origcomp INT,
--@v_inactive_destcomp INT,
@vordhdrnumber int


If exists(Select 1 from orderheader where ord_number = @p_ordnumber)
BEGIN
    select @vordhdrnumber = ord_hdrnumber from orderheader where ord_number = @p_ordnumber
	SELECT @v_inactive_ordcomp = COUNT(cmp1.cmp_id),
	       @v_inactive_billto = COUNT(cmp2.cmp_id) --,
	       --@v_inactive_origcomp = COUNT(orig.cmp_id),
	      -- @v_inactive_destcomp = COUNT(dest.cmp_id)
	FROM orderheader 
		LEFT OUTER JOIN company AS cmp1 ON orderheader.ord_company = cmp1.cmp_id
		AND cmp1.cmp_active = 'N'
	    LEFT OUTER JOIN company AS cmp2 ON orderheader.ord_billto = cmp2.cmp_id
		AND (cmp2.cmp_active = 'N' or cmp2.cmp_billto = 'N')
		--LEFT OUTER JOIN company AS orig ON orderheader.ord_originpoint = orig.cmp_id
		--AND (orig.cmp_active = 'N' or orig.cmp_shipper = 'N')  
	 	--LEFT OUTER JOIN company AS dest ON orderheader.ord_destpoint = dest.cmp_id
		--AND (dest.cmp_active = 'N' or dest.cmp_consingee = 'N')
	WHERE orderheader.ord_number = @p_ordnumber

	SELECT @p_total_inactive = @v_inactive_ordcomp + @v_inactive_billto --+ @v_inactive_origcomp + @v_inactive_destcomp
	
	-- check for invalid pickups
	if exists (select 1 from stops s join company c on s.cmp_id = c.cmp_id
	 where ord_hdrnumber = @vordhdrnumber and (c.cmp_shipper = 'N' or cmp_active = 'N') and s.stp_type = 'PUP')
	 select @p_total_inactive = @p_total_inactive + 1
	 
	-- check for invalid delivery companies 
	if exists (select 1 from stops s join company c on s.cmp_id = c.cmp_id
	 where ord_hdrnumber = @vordhdrnumber and (c.cmp_consingee = 'N' or cmp_active = 'N') and s.stp_type = 'DRP')
	 select @p_total_inactive = @p_total_inactive + 1
END
ELSE
BEGIN
	-- Return -1 letting UI know that we didn't find anything.
	SELECT @p_total_inactive = -1
END

GO
GRANT EXECUTE ON  [dbo].[copyorder_compvalidation_sp] TO [public]
GO
