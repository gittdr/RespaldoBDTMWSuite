SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_paperworkcheck_sp]
	@ord_hdrnumber		integer, 
	@lgh_number		integer
AS
/*
PTS34565 added code to retrieve by order ornly or by leg (all orders on leg)
  to support consolidated tirp where papwerworki is by leg had to union a bunch of dselects
  to build th e paperwork records where they don't exist
 * 10/31/2007.01 ? PTS40115 - JGUO ? convert old style outer join syntax to ansi outer join syntax.

PTS 43837 add indication of who requires it. Ewmwmber the return set for paperwork fields must be null where
    no paperwork record exists 
*/
Declare @PaperWorkCheckLevel varchar(6),@ordnumber varchar(12),@movnumber int ,@lghstartdate datetime
declare @tmpTable table(ord_hdrnumber int not null, ord_number varchar(12) not null, abbr varchar(6) not null, ord_billto varchar(8) null);
declare @billto varchar(8),@defaultrequirement char(1)
declare @billdoctypes table (bdt_doctype varchar(6) null
,bdt_required_for_application char(1) null
,ord_hdrnumber int null
, bdt_required_for_dispatch CHAR(1) NULL
)
if exists (select 1 from generalinfo where gi_name = 'PaperworkMode' and gi_string1 = 'B')
   select @defaultrequirement  = ''
else
   select @defaultrequirement = 'B'

if @ord_hdrnumber > 0 select @ordnumber = ord_number,@billto = ord_billto  from orderheader where ord_hdrnumber = @ord_hdrnumber


   
select @movnumber = mov_number,@lghstartdate = lgh_startdate from legheader where legheader.lgh_number = @lgh_number
select @PaperWorkCheckLevel = gi_string1 from generalinfo where gi_name = 'PaperWorkCheckLevel'

If @ord_hdrnumber > 0
  BEGIN
    Insert into @billdoctypes (bdt_doctype,bdt_required_for_application, bdt_required_for_dispatch)
    select bdt_doctype,isnull(bdt_required_for_application,'B'), IsNull(billdoctypes.bdt_required_for_dispatch,'N')
    from billdoctypes where cmp_id = @billto 
    --BEGIN PTS 51905 SPN
    --and isnull(bdt_inv_required ,'Y') = 'Y'
    and (isnull(bdt_inv_required ,'Y') = 'Y' OR IsNull(billdoctypes.bdt_required_for_dispatch,'N') = 'Y')
    --END PTS 51905 SPN

-- Get the paperwork for the Order/Leg
    SELECT labelfile.name,   
	paperwork.pw_received,   
	paperwork.ord_hdrnumber,   
	paperwork.abbr,   
	labelfile.code,   
	labelfile.abbr,   
	paperwork.pw_dt,
	0 'Required',
	paperwork.last_updatedby,
	paperwork.last_updateddatetime,
	isNull(paperwork.lgh_number , isNull(@lgh_number,0)) lgh_number,
    ord_number = @ordnumber,
    @ord_hdrnumber,
    isnull(bdt_required_for_application,@defaultrequirement)
    , IsNull(bdt.bdt_required_for_dispatch,'N') AS bdt_required_for_dispatch
    --pts40115 jguo outer join conversion
    FROM labelfile LEFT OUTER JOIN paperwork on (labelfile.abbr = paperwork.abbr and paperwork.ord_hdrnumber = @ord_hdrnumber and paperwork.lgh_number = @lgh_number)
    left outer join @billdoctypes bdt on paperwork.abbr =  bdt.bdt_doctype
    WHERE labelfile.labeldefinition = 'PaperWork' AND  
	isnull(labelfile.retired ,'N') <> 'Y' 
	--PTS 38332 EMK  Replaced line removed in PTS 38028.  
	--PTS 38332 EMK 
  END
else 
  BEGIN

    -- if not in ppwrk by leg and this is not the first leg, return nothing.
    if @PaperWorkCheckLevel <> 'LEG' and 
       exists (select 1 from legheader where mov_number = @movnumber
               and lgh_startdate < @lghstartdate)
       return
    else
      BEGIN
    -- if not in ppwrk by leg and this is not the first leg, return nothing.
      /* in order to get all the orders on a leg and have the proc create records for each labelfile paperwork entry even if
         the paperwork does not exist.  union result sets for each order on the leg - coded for max od 20 orders  on leg
      */
       -- get all orders on the leg             
      insert into @tmpTable
      select distinct stops.ord_hdrnumber, orderheader.ord_number, labelfile.abbr, ord_billto
      from stops inner join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber,
           labelfile
      where labelfile.labeldefinition = 'PaperWork'
	    and isnull(labelfile.retired ,'N') <> 'Y'
        and lgh_number = @lgh_number
        and stp_type in ('PUP','DRP')
      order by stops.ord_hdrnumber, orderheader.ord_number

      Insert into @billdoctypes (bdt_doctype,bdt_required_for_application,ord_hdrnumber, bdt_required_for_dispatch)
      select distinct bdt_doctype,isnull(bdt_required_for_application,'B'),tt.ord_hdrnumber, IsNull(billdoctypes.bdt_required_for_dispatch,'N')
      from (select distinct ord_hdrnumber from  @tmptable) tt
      join orderheader on tt.ord_hdrnumber = orderheader.ord_hdrnumber
      left outer join  billdoctypes on ord_billto = cmp_id 
      where isnull(bdt_inv_required,'Y') = 'Y'

/* null values in the paperwork.ord_hdrnumber field signal w_paperworkcheck(retrieveit) to add record */
/* duplicate fields (paperwork.abbr/labelfile.abbr) allow you to display
   requirements (labelfile.) on the datawindow but set update values in the paperwork fields */
    if @PaperWorkCheckLevel = 'LEG'
      SELECT labelfile.name,   
	  paperwork.pw_received,   
	  paperwork.ord_hdrnumber,     
	  paperwork.abbr,   
	  labelfile.code,   
	  labelfile.abbr,   
	  paperwork.pw_dt,
	  0 'Required',
	  paperwork.last_updatedby,
	  paperwork.last_updateddatetime,
	  isNull(paperwork.lgh_number , isNull(@lgh_number,0)) lgh_number,
      tmpTable.ord_number,
      tmpTable.ord_hdrnumber,
      isnull(bdt_required_for_application,@defaultrequirement)
      , IsNull(bdt.bdt_required_for_dispatch, 'N') AS bdt_required_for_dispatch
      from @tmpTable as tmpTable 
      left outer join paperwork on tmpTable.ord_hdrnumber = paperwork.ord_hdrnumber
                                                          and tmpTable.abbr = paperwork.abbr
                                                          and paperwork.lgh_number =  @lgh_number
      join labelfile on labelfile.abbr = tmpTable.abbr
      left outer join @billdoctypes bdt on tmptable.ord_hdrnumber =  bdt.ord_hdrnumber
                      and tmptable.abbr = bdt.bdt_doctype
      where labelfile.labeldefinition = 'PaperWork'
	    and isnull(labelfile.retired ,'N') <> 'Y'

    Else
      SELECT labelfile.name,   
	  paperwork.pw_received,   
	  paperwork.ord_hdrnumber,   
	  paperwork.abbr,   
	  labelfile.code,   
	  labelfile.abbr,   
	  paperwork.pw_dt,
	  0 'Required',
	  paperwork.last_updatedby,
	  paperwork.last_updateddatetime,
	  isNull(paperwork.lgh_number , isNull(@lgh_number,0)) lgh_number,
      tmpTable.ord_number,
      tmpTable.ord_hdrnumber,
      isnull(bdt_required_for_application,@defaultrequirement)
      , IsNull(bdt.bdt_required_for_dispatch,'N') AS bdt_required_for_dispatch
      from @tmpTable as tmpTable 
      left outer join paperwork on tmpTable.ord_hdrnumber = paperwork.ord_hdrnumber
                                                          and tmpTable.abbr = paperwork.abbr
      inner join labelfile on labelfile.abbr = tmpTable.abbr
      left outer join @billdoctypes bdt on tmptable.ord_hdrnumber =  bdt.ord_hdrnumber
                      and tmptable.abbr = bdt.bdt_doctype
      where labelfile.labeldefinition = 'PaperWork'
	    and isnull(labelfile.retired ,'N') <> 'Y'
   end
  END

GO
GRANT EXECUTE ON  [dbo].[d_paperworkcheck_sp] TO [public]
GO
