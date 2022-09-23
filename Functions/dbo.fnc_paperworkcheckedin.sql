SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[fnc_paperworkcheckedin]
(	
	@lgh_number int
)

returns int

as

begin

declare @paperwork int

select 

  @paperwork = CASE (  
       isnull((SELECT count(*) - SUM(CASE paperwork.pw_received  
              WHEN 'Y' THEN 1  
              ELSE 0  
             END)   
         FROM labelfile inner join paperwork on labelfile.abbr = paperwork.abbr  
                   and paperwork.ord_hdrnumber = lgh.ord_hdrnumber  
                   and (paperwork.lgh_number = case when (select coalesce(gi_string1,'Order') from generalinfo where gi_name = 'PaperWorkCheckLevel') <> 'Leg' then (select min(lgh_number) from paperwork where paperwork.ord_hdrnumber = lgh.ord_hdrnumber) else paperwork.lgh_number end or lgh_number is null)  
         WHERE labeldefinition = 'PaperWork'  
           and retired <> 'Y'  
           and 'A' = (SELECT gi_string1 FROM generalinfo WHERE gi_name = 'PaperWorkMode')  
           and lgh.ord_hdrnumber > 0), 0)  
  
       +  
  
       isnull((SELECT SUM(CASE bdt_inv_required  
             WHEN 'Y' THEN 1  
             ELSE 0   
             END) -  
           SUM(CASE paperwork.pw_received  
             WHEN 'Y' THEN 1  
             ELSE 0  
            END)  
         FROM BillDoctypes left outer JOIN paperwork on paperwork.ord_hdrnumber = lgh.ord_hdrnumber  
                      and paperwork.abbr = BillDoctypes.bdt_doctype  
                      and (paperwork.lgh_number = case when (select coalesce(gi_string1,'Order') from generalinfo where gi_name = 'PaperWorkCheckLevel') <> 'Leg' then (select min(lgh_number) from paperwork where paperwork.ord_hdrnumber = lgh.ord_hdrnumber
) else paperwork.lgh_number end or lgh_number is null)  
          inner join orderheader oh on paperwork.ord_hdrnumber = oh.ord_hdrnumber  
         WHERE LEN(bdt_doctype) > 0  
         AND IsNull(bdt_inv_required,'Y') = 'Y'  
         and BillDoctypes.cmp_id = oh.ord_billto  
         and 'B' = (SELECT gi_string1 FROM generalinfo WHERE gi_name = 'PaperWorkMode')), 0)  
  
       +   
  
       isnull((SELECT SUM(CASE cpw.cpw_inv_required  
             WHEN 'Y' THEN 1  
             ELSE 0   
             END) -  
           SUM(CASE paperwork.pw_received  
             WHEN 'Y' THEN 1  
             ELSE 0  
            END)  
         FROM chargetypepaperwork cpw INNER JOIN chargetype cht ON cpw.cht_number = cht.cht_number  
                 INNER JOIN invoicedetail ivd ON cht.cht_itemcode = ivd.cht_itemcode  
                 INNER JOIN invoiceheader ivh ON ivd.ivh_hdrnumber = ivh.ivh_hdrnumber  
                 INNER JOIN paperwork on paperwork.ord_hdrnumber = ivd.ord_hdrnumber  
                      and paperwork.abbr = cpw.cpw_paperwork  
                      and (paperwork.lgh_number = case when (select coalesce(gi_string1,'Order') from generalinfo where gi_name = 'PaperWorkCheckLevel') <> 'Leg' then (select min(lgh_number) from paperwork where paperwork.ord_hdrnumber = lgh.ord_hdrnumber
) else paperwork.lgh_number end or lgh_number is null)  
                 left outer join chargetypepaperworkcmp cpwcmpinner on cht.cht_number = cpwcmpinner.cht_number  
         WHERE ivd.ord_hdrnumber = lgh.ord_hdrnumber  
           and ((cht.cht_paperwork_requiretype = 'O'  
          and ivh.ivh_billto = cpwcmpinner.cmp_id)  
          or (cht.cht_paperwork_requiretype = 'E'  
          and ivh.ivh_billto <> cpwcmpinner.cmp_id)  
          or cht.cht_paperwork_requiretype = 'A')), 0)  
  
      )  
     WHEN 0 THEN 1  
     ELSE -1  
    END 

from legheader lgh where lgh.lgh_number = @lgh_number

return @paperwork

end

GO
GRANT EXECUTE ON  [dbo].[fnc_paperworkcheckedin] TO [public]
GO
