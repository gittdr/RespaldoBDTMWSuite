SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ltl_route_detail_summary_sp] (
                                                 @p_stoplist varchar(8000))
AS
declare @ls_displaycurr varchar(60)
declare @results table (fgt_count		int,
						fgt_count2		int,
						fgt_volume		float,
						fgt_weight		float,
						ord_hdrnumber	int,
						total_charges	money)

select @ls_displaycurr = gi_string1
  from generalinfo
 where gi_name = 'TrailerManifestDisplayCurrency'
insert into @results (fgt_count, fgt_count2, fgt_volume, fgt_weight, ord_hdrnumber)
select isnull(sum(fgt_count),0), isnull(sum(fgt_count2),0), isnull(sum(isnull(fgt_volume,0.00)),0.00), isnull(sum(fgt_weight),0), s.ord_hdrnumber
  from freightdetail f
  join stops s on s.stp_number = f.stp_number and s.ord_hdrnumber > 0 and (s.stp_event = 'XDU' or s.stp_type = 'DRP')
 where s.stp_number in (select value from CSVStringsToTable_fn(@p_stoplist))
 group by ord_hdrnumber

update @results
   set total_charges = dbo.fn_currency_conversion(ord_totalcharge, getdate(), ord_currency, @ls_displaycurr)
 from orderheader o, @results r
where o.ord_hdrnumber = r.ord_hdrnumber

select sum(fgt_count) as 'totalcount',
	   sum(fgt_count2) as 'totalcount2',
	   sum(fgt_volume) as 'totalvolume',
 	   sum(fgt_weight) as 'totalweight',
	   sum(total_charges) as 'totalcharges',
	   0.00 as 'revpermile',
	   @ls_displaycurr as 'curr_conv_disp'
  from @results

GO
GRANT EXECUTE ON  [dbo].[d_ltl_route_detail_summary_sp] TO [public]
GO
