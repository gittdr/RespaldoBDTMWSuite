SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE        proc [dbo].[dx_get_archive_by_ordernumber]
(
	@dx_importId varchar(8),
	@dx_ordernumber varchar(30),
	@trp_id varchar(20) = NULL
)
as

/*******************************************************************************************************************  
  Object Description:
  dx_get_archive_by_ordernumber

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  07/29/2016   David Wilks      104540       suppress event changes that aren't handled properly in frmMain.DoFindEDIChanges
											 refactor using dx_archive_header and dx_archive_detail instead of dx_archive
********************************************************************************************************************/

begin
	DECLARE @p_sourcedate datetime, @ReserveSourceDate datetime
	SELECT @p_sourcedate = MAX(dx_sourcedate)
	FROM dx_archive_header WITH (NOLOCK)
	WHERE dx_importid = @dx_importId
	   AND dx_ordernumber = @dx_ordernumber
	   AND dx_orderhdrnumber > 0
	   AND dx_movenumber > 0
	   AND dx_updated <> 'C'  --FMM added 7/11/2008
	   AND dx_trpid = ISNULL(@trp_id,dx_trpid)

   	SELECT @ReserveSourceDate = MAX(dx_sourcedate)
	FROM dx_Archive_header WITH (NOLOCK)
	WHERE dx_importid = @dx_importId
	   AND dx_ordernumber = @dx_ordernumber
	   AND dx_orderhdrnumber > 0
	   AND dx_movenumber > 0
	   AND IsNull(dx_updated,'') <> 'C'  -- allow null dx_updated so that currently processing 204 is eligible
	   AND dx_trpid = ISNULL(@trp_id,dx_trpid)


	SELECT	ah.dx_importid, ah.dx_sourcename, ah.dx_sourcedate, a.dx_seq, ah.dx_updated, ah.dx_accepted, ah.dx_manifestnumber, 
			a.dx_manifeststop, a.dx_field001, a.dx_field002, 
			CASE when a.dx_field001 = '03' then isnull(b.dx_field003, a.dx_field003) else a.dx_field003 end as 'dx_field003', 
			a.dx_field004, a.dx_field005, a.dx_field006, a.dx_field007, 
			a.dx_field008, a.dx_field009, a.dx_field010, a.dx_field011, a.dx_field012, a.dx_field013, a.dx_field014, a.dx_field015, 
			a.dx_field016, a.dx_field017, a.dx_field018, a.dx_field019, a.dx_field020, a.dx_field021, a.dx_field022, a.dx_field023, 
			a.dx_field024, a.dx_field025, a.dx_field026, a.dx_field027, a.dx_field028, a.dx_field029, 
			CASE when a.dx_field001 = '03' and b.dx_field003 <> a.dx_field003 then 'EVENT ' + a.dx_field003 + ' TO: ' + b.dx_field003 else a.dx_field030 end as 'dx_field030', 
			ah.dx_orderhdrnumber, ISNULL(orderheader.mov_number, 0) as 'dx_movenumber', a.dx_stopnumber, a.dx_freightnumber, ah.dx_ordernumber, 
			ah.dx_docnumber, a.dx_ident, ah.dx_doctype,ah.dx_processed 
	FROM
			dbo.dx_archive_header ah WITH (NOLOCK) 
			join dbo.dx_Archive_detail a WITH (NOLOCK) on ah.dx_archive_header_id = a.dx_Archive_header_id
	LEFT OUTER JOIN dbo.dx_Archive_header bh WITH (NOLOCK) on bh.dx_sourcedate = @ReserveSourceDate 
	LEFT OUTER JOIN dbo.dx_Archive_detail b WITH (NOLOCK) on bh.dx_Archive_header_id = b.dx_Archive_header_id and a.dx_field001 = b.dx_field001 and a.dx_stopnumber = b.dx_stopnumber and a.dx_field001 = '03'
	LEFT OUTER JOIN
			dbo.orderheader WITH (NOLOCK)
	ON
			ah.dx_orderhdrnumber = orderheader.ord_hdrnumber
	WHERE
			(ah.dx_sourcedate = @p_sourcedate)
	AND
			(ah.dx_ordernumber =@dx_ordernumber) 
	AND 
			(ah.dx_importid = @dx_importId) 
	AND 
			(ah.dx_orderhdrnumber>0)
	AND
			(ah.dx_movenumber>0)
	ORDER BY
			a.dx_ident
end


GO
GRANT EXECUTE ON  [dbo].[dx_get_archive_by_ordernumber] TO [public]
GO
