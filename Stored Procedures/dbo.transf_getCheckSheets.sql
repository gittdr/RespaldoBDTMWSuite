SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getCheckSheets]
      (
            @branch varchar(12)
            , @supplier varchar(8)
            , @refnum varchar (30)
            , @datefrom datetime
            , @dateto datetime
            , @route varchar(12)
            , @partno varchar(12)
            , @dock varchar(12)
			, @transf_user_id int
      )
AS

set nocount on
	declare @car_id varchar(8)

      if @branch is null or ltrim(rtrim(@branch)) = ''
            set @branch = ''
            
      if @refnum is null or ltrim(rtrim(@refnum)) = ''
            set @refnum = ''

      if @supplier is null or ltrim(rtrim(@supplier)) = ''
            set @supplier = ''
            
      --the dates cannot be empty string or null
      set @datefrom = convert(datetime, convert(varchar(12),@datefrom, 101) + ' 00:00:00')
      set @dateto = convert(datetime, convert(varchar(12),@dateto, 101) + ' 23:59:59')
      
      if @route is null or ltrim(rtrim(@route)) = ''
            set @route = ''

      if @partno is null or ltrim(rtrim(@partno)) = ''
            set @partno = ''

      if @dock is null or ltrim(rtrim(@dock)) = ''
            set @dock = ''

      SELECT DISTINCT
            ord_route
            , oh.ord_number
            , poh_supplier
            , a.cmp_altid
            , a.cmp_name 
            , poh_deliverdate
			, poh_pickupdate
            , poh_refnum
      from partorder_header ph
            JOIN partorder_routing pr ON ph.poh_identity = pr.poh_identity
            JOIN orderheader oh ON pr.por_ordhdr = oh.ord_hdrnumber
            JOIN partorder_detail pd ON ph.poh_identity = pd.poh_identity
            JOIN stops ON stops.cmp_id = ph.poh_supplier
			Join transf_UserBranches ub on ph.poh_branch = ub.brn_id and ub.transf_user_id = @transf_user_id	--join for the user branch
			JOIN company_alternates c ON c.ca_id = poh_supplier
			join company a on c.ca_alt = a.cmp_id
				and a.cmp_revtype1 =  ub.brn_id
				and a.cmp_othertype1 = 'ACTV'
				and  ub.transf_user_id = @transf_user_id --join for the supplier

      WHERE (ph.poh_branch = @branch or @branch='')
            AND (ph.poh_supplier = @supplier OR @supplier = '')
            AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, ph.poh_deliverdate ))) BETWEEN @datefrom AND @dateto
            AND (pd.pod_partnumber = @partno OR @partno = '')
            AND (ph.poh_dock = @dock OR @dock = '')
            AND (ph.poh_refnum = @refnum OR @refnum = '')
            AND (oh.ord_route = @route OR @route = '')
SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_getCheckSheets] TO [public]
GO
