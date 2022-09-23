SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDIOrderDocForDupCompare]
	@p_SourceDate DATETIME
AS

      select 
    dxad.dx_ident,
    dxah.dx_importid,
    dxah.dx_sourcename,
    dxah.dx_sourcedate,
    convert(int, dxad.dx_seq) dx_seq,
    dxah.dx_updated,
    dxah.dx_accepted,
    dxah.dx_ordernumber,
    dxah.dx_orderhdrnumber,
    dxah.dx_movenumber,
    dxad.dx_stopnumber,
    dxad.dx_freightnumber,
    dxah.dx_docnumber,
    dxah.dx_manifestnumber,
    dxad.dx_manifeststop,
    dxah.dx_batchref,
    dxad.dx_field001,
    dxad.dx_field002,
    dxad.dx_field003,
    dxad.dx_field004,
    dxad.dx_field005,
    dxad.dx_field006,
    dxad.dx_field007,
    dxad.dx_field008,
    dxad.dx_field009,
    dxad.dx_field010,
    dxad.dx_field011,
    dxad.dx_field012,
    dxad.dx_field013,
    dxad.dx_field014,
    dxad.dx_field015,
    dxad.dx_field016,
    dxad.dx_field017,
    dxad.dx_field018,
    dxad.dx_field019,
    dxad.dx_field020,
    dxad.dx_field021,
    dxad.dx_field022,
    dxad.dx_field023,
    dxad.dx_field024,
    dxad.dx_field025,
    dxad.dx_field026,
    dxad.dx_field027,
    dxad.dx_field028,
    dxad.dx_field029,
    dxad.dx_field030,
    dxad.dx_field031,
    dxad.dx_field032,
    dxad.dx_field033,
    dxad.dx_field034,
    dxad.dx_field035,
    dxah.dx_doctype,
    dxah.dx_createdby,
    dxah.dx_createdate,
    dxah.dx_updatedby,
    dxah.dx_updatedate,
    dxah.dx_processed,
    dxah.dx_trpid,
    dxah.dx_sourcedate_reference,
    dxah.dx_billto,
	dxah.dx_Archive_header_id
  from dbo.dx_Archive_header dxah (nolock)
    left outer join dbo.dx_Archive_detail dxad (nolock)
      on dxah.dx_Archive_header_id = dxad.dx_Archive_header_id
	where dxah.dx_sourcedate=@p_SourceDate 

GO
GRANT EXECUTE ON  [dbo].[dx_EDIOrderDocForDupCompare] TO [public]
GO
