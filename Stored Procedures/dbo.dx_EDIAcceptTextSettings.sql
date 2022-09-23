SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_EDIAcceptTextSettings]
	@p_OrderHeaderNumber varchar(50)
as


declare @v_ordhdr int, @v_tpid varchar(20), @v_user varchar(20)

select @v_ordhdr = ord_hdrnumber
     , @v_tpid = ord_editradingpartner
  from orderheader
 where ord_number = @p_OrderHeaderNumber

if isnull(@v_ordhdr, 0) = 0 return
if isnull(@v_tpid,'') = '' return

exec dbo.dx_gettmwuser @v_user OUTPUT

select etp_AllowAcceptText, ISNULL(etp_DefaultAcceptText,'') AS etp_DefaultAcceptText,
       ord_number, etp_partnerName, ISNULL(labelfile.[name], ord_status) AS ord_status, ord_edipurpose,
       rtrim(ocity.cty_name) + ', ' + ocity.cty_state AS ord_origincity,
       rtrim(dcity.cty_name) + ', ' + dcity.cty_state AS ord_destcity,
       convert(varchar, ord_startdate, 1) + ' ' + convert(varchar, ord_startdate, 8) AS ord_startdate,
       (select count(1) from stops where ord_hdrnumber = @v_ordhdr) AS stp_count,
       convert(varchar, getdate(), 1) + ' ' + convert(varchar, getdate(), 8) AS ord_declinedate,
       @v_user AS tmw_user
  from orderheader
 inner join edi_tender_partner
    on orderheader.ord_editradingpartner = etp_partnerID
 inner join city ocity
    on orderheader.ord_origincity = ocity.cty_code
 inner join city dcity
    on orderheader.ord_destcity = dcity.cty_code
  left join labelfile
    on orderheader.ord_status = labelfile.abbr
   and labelfile.labeldefinition = 'DispStatus'
 where ord_hdrnumber = @v_ordhdr

GO
GRANT EXECUTE ON  [dbo].[dx_EDIAcceptTextSettings] TO [public]
GO
