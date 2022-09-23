SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROC [dbo].[d_latetrip_data_sp]
as
/* Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	--------------------------------------------
	09/24/2002	Vern Jewett		15562	(none)	Original, replaces embedded SQL in PB DW 
												d_latetrip_data
	10/30/2002	Vern Jewett		15942	vmj1	Add ckc_comment and ckc_commentlarge to the
												result set.
	05/13/2003	Vern Jewett		17075	vmj2	Remove all usage of the notes table, and add
												lgh_number to the result set.
	05/22/2003	Vern Jewett		18019	vmj3	lgh_etaalert1 will now contain 0/1/2/3 instead
												of Y/N.

 * 09/02/2005 - Jason Bauwin - Set the Transaction Isolation level to ignore locked tables 
 *                            so the agent does not get deadlocked because of other locking in the database
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 **/


--PTS 29667
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


create table #trc
	(trc_number		varchar(8)	null)

create table #ckc
	(ckc_number			int				null
	,ckc_tractor		char(8)			null
	,trc_gps_date		datetime		null
	,trc_gps_desc		varchar(50)		null
	--vmj1+
	,ckc_comment		varchar(254)	null
	,ckc_commentlarge	varchar(254)	null
	--vmj1-
	)
	

insert into #trc
		(trc_number)
  select distinct lgh_tractor
  from	legheader
  where	lgh_active = 'Y'
	--vmj3+
	and	lgh_etaalert1 in ('1', '2', '3')
--	and	lgh_etaalert1 = 'Y'
	--vmj3-
	and	ord_hdrnumber <> 0
	and lgh_outstatus <> 'CMP' 

--PTS 22043  same performance problem we found under 21905
insert into #ckc (ckc_tractor, trc_gps_date)
select t.trc_number,
       (select max(ck.ckc_date) 
	 from checkcall ck 
        where ck.ckc_tractor = t.trc_number 
          and ck.ckc_date <= getdate() )
  from	#trc t

update	#ckc
  set	ckc_number = c.ckc_number
		,trc_gps_desc = convert(varchar(20), convert(money, c.ckc_latseconds) / 3600, 2) + 
						replicate('N, ', sign(isnull(c.ckc_latseconds, 0))) + 
						convert(varchar(20), convert(money, c.ckc_longseconds) / 3600, 2) + 
						replicate('W', sign(isnull(c.ckc_longseconds, 0)))
		--vmj1+
		,ckc_comment = c.ckc_comment
		,ckc_commentlarge = c.ckc_commentlarge
		--vmj1-
  from	#ckc tc
		,checkcall c
  where	c.ckc_tractor = tc.ckc_tractor
	and	c.ckc_date = tc.trc_gps_date


--Final select..
select	o.ord_number
		,l.lgh_tractor   
		,l.lgh_driver1   
		,l.lgh_driver2   
		,l.lgh_startdate   
		,l.lgh_enddate  
		,l.lgh_startcty_nmstct
		,l.lgh_endcty_nmstct  
		,l.lgh_outstatus
		,l.mpp_teamleader 
		,c1.cty_region1 ord_originregion1
		,c2.cty_region1 ord_destregion1
		--vmj2+
--		,n1.not_text pup_note
--		,n2.not_text drp_note
		--vmj2-
		,o.ord_revtype1
		,o.ord_revtype2
		,o.ord_revtype3
		,o.ord_revtype4 
		,ck.trc_gps_desc
		,ck.trc_gps_date
		,c1.cty_nmstct ord_origincty_nmstct
		,c2.cty_nmstct ord_destcty_nmstct
		,l.mpp_type1
		,l.mpp_type2
		,l.mpp_type3
		,l.mpp_type4
		,l.ord_hdrnumber
		--vmj1+
		,ck.ckc_comment
		,ck.ckc_commentlarge
		--vmj1-
		--vmj2+
		,l.lgh_number
		--vmj2-
		--vmj3+
		,l.lgh_carrier
		,l.lgh_etaalert1
		,0 as email_count
		--vmj3-
		,l.lgh_eta_cmp_list
  from	legheader l (nolock) LEFT OUTER JOIN #ckc ck ON ck.ckc_tractor = l.lgh_tractor
		--vmj2+
--		,notes n1
		--vmj2-
		,orderheader o (nolock)
		,city c1 (nolock)
		--vmj2+
--		,notes n2
		--vmj2-
		,city c2 (nolock)
		
  where	l.lgh_active = 'Y'
	--vmj3+
	and	l.lgh_etaalert1 in ('1', '2', '3')
--	and	l.lgh_etaalert1 = 'Y'
	--vmj3-
	--vmj2+
--	and	n1.nre_tablekey =* convert(char(18), l.mov_number)
--	and	n1.ntb_table = 'ETA'
--	and	n1.not_type = 'ETAPUP'
--	and	n1.not_sequence = 1
--	and	n2.nre_tablekey =* convert(char(18), l.mov_number)
--	and	n2.ntb_table = 'ETA'
--	and	n2.not_type = 'ETADRP'
--	and	n2.not_sequence = 1
	--vmj2-
	and	l.ord_hdrnumber <> 0
	and	l.lgh_outstatus <> 'CMP' 
	and	o.ord_hdrnumber = l.ord_hdrnumber 
	and	c1.cty_code = o.ord_origincity 
	and	c2.cty_code = o.ord_destcity
	--and	ck.ckc_tractor =* l.lgh_tractor

SET TRANSACTION ISOLATION LEVEL READ COMMITTED


GO
GRANT EXECUTE ON  [dbo].[d_latetrip_data_sp] TO [public]
GO
