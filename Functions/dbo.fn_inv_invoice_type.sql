SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_inv_invoice_type] (@ivh_hdrnumber INTEGER, @dbh_id INTEGER)

RETURNS VARCHAR (6)
BEGIN
	
	DECLARE @result VARCHAR(6)
	DECLARE @billtotype VARCHAR(6)
	
	DECLARE @temp_bat table 
		(ivh_billto VARCHAR(8)
		,bat_invoice_type VARCHAR (6)
		,bat_revtype1 VARCHAR(6)
		,bat_revtype2 VARCHAR(6)
		,bat_revtype3 VARCHAR(6)
		,bat_revtype4 VARCHAR(6)
		,sum1 INTEGER
		,sum2 INTEGER
		,sum3 INTEGER
		,sum4 INTEGER
		)
		
	INSERT INTO @temp_bat
		SELECT bat_billto
			,bat_invoice_type
			,bat_revtype1
			,bat_revtype2
			,bat_revtype3
			,bat_revtype4
			,sum1 = Case When IsNull (b.bat_revtype1, '(ALL)') = '(ALL)' Then 0 Else 1 End
			,sum2 = Case When IsNull (b.bat_revtype2, '(ALL)') = '(ALL)' Then 0 Else 1 End
			,sum3 = Case When IsNull (b.bat_revtype3, '(ALL)') = '(ALL)' Then 0 Else 1 End
			,sum4 = Case When IsNull (b.bat_revtype4, '(ALL)') = '(ALL)' Then 0 Else 1 End
		FROM branch_assignedtype b
		join invoiceheader t on b.bat_billto = t.ivh_billto
		WHERE (b.bat_revtype1 = t.ivh_revtype1 or isnull(bat_revtype1, '(ALL)') = '(ALL)')	 
			AND (b.bat_revtype2 = t.ivh_revtype2 or isnull(bat_revtype2, '(ALL)') = '(ALL)')
			AND (b.bat_revtype3 = t.ivh_revtype3 or isnull(bat_revtype3, '(ALL)') = '(ALL)')
			AND (b.bat_revtype4 = t.ivh_revtype4 or isnull(bat_revtype4, '(ALL)') = '(ALL)')
			and ISNULL(b.bat_inv_group, '') = IsNull (t.ivh_splitgroup, '')
			and (t.ivh_hdrnumber = @ivh_hdrnumber or isnull(t.dbh_id,-1) = @dbh_id)
		
		IF (select count (*) from @temp_bat) > 0 Begin /*PTS 69791 NLOKE*/
			update @temp_bat
			set bat_invoice_type = cmp_invoicetype 
			from @temp_bat t 
			join company c on c.cmp_id = t.ivh_billto 
			where IsNull (bat_invoice_type, '') NOT IN ('BTH', 'INV', 'MAS', 'NONE')
		End Else Begin /*PTS 69791 NLOKE*/
			insert into @temp_bat (bat_invoice_type)
				--select c.cmp_invoicetype 
				--from company c
				--join invoiceheader i on c.cmp_id = i.ivh_billto
				--where (i.ivh_hdrnumber = @ivh_hdrnumber or isnull(i.dbh_id,-1) = @dbh_id)
				/* MTC 20140716*/
				select cmp_invoicetype from 
					(
					select c.cmp_invoicetype 
					from company c with (nolock) inner join invoiceheader i with (nolock) on c.cmp_id = i.ivh_billto
					where (i.ivh_hdrnumber = @ivh_hdrnumber)
					UNION
					select c.cmp_invoicetype 
					from company c with (nolock) inner join invoiceheader i with (nolock) on c.cmp_id = i.ivh_billto
					where i.dbh_id is not null and i.dbh_id = @dbh_id
					) a
				group by cmp_invoicetype

		End
		

	
	SELECT top 1 @result = bat_invoice_type
		FROM @temp_bat
		order by sum1+sum2+sum3+sum4 desc, sum1 desc, sum2 desc, sum3 desc, sum4 desc,bat_revtype1 desc,bat_revtype2 desc,bat_revtype3 desc,bat_revtype4 desc
			
	RETURN COALESCE (@result, @billtotype)	
END
GO
GRANT EXECUTE ON  [dbo].[fn_inv_invoice_type] TO [public]
GO
