SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ltsl_postprocess_companyUpdate] @ord_number varchar(12)--,@trp_id varchar(20) --optional

/* 
 * NAME:
 * dbo.ltsl_postprocess_companyUpdate
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Custom stored procedure for postprocessing of EDI inbound load tenders. 
 * updates name and address of existing rows in company table based on altid in the 204
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * NONE
 *
 * PARAMETERS:
 * @ord_number::varchar(12)::input - TMW order number
 * @trp_id::varchar(20)::input - Optional input parm with trading partner id from 204
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 *	06.12.2013.01 - (TMW) - Initial version
 * exec ltsl_postprocess_companyUpdate 18692
*/

AS

DECLARE @dx_sourceDate DATETIME
		,@loopCounter INT
		,@companyCounter INT
		,@cmp_id varchar(8)
		,@cmp_name varchar(100)
		,@cmp_address1 varchar(100)
		,@cmp_address2 varchar(100)
		,@cmp_cityname varchar(18)
		,@cmp_state char(2)
		,@cmp_zip varchar(10)
		,@cmp_country char(3)
		,@cmp_primaryphone varchar(20)
		,@stp_contact  varchar(30)
		,@stp_phonenumber varchar(20)
		,@dx_ident  int
		,@sql	NVARCHAR(max)
		,@where	NVARCHAR(max)
		,@updFields INT


DECLARE @companyData TABLE( rec_id INT IDENTITY(1,1) NOT NULL,
							
							 cmp_id varchar(8) not null,
							 dx_ident int not null,
							dx_field001 varchar(2)not null ,
							 cmp_name varchar(100) null,
							 cmp_address1 varchar(100) null,
							 cmp_address2 varchar(100) null,
							 cmp_cityname varchar(18) null,
							 cmp_state char(2) null,
							 cmp_zip varchar(10) null,
							 cmp_country char(3) null,
							 cmp_primaryphone varchar(20) null,
							 stp_contact varchar(30) null ,
							 stp_phonenumber varchar(20) null
						  )
						    
 BEGIN
 
	SELECT @dx_sourceDate =  ISNULL(MAX(dx_sourcedate),'12/31/2049 23:59:59') 
	 FROM dx_archive with(NOLOCK)
	WHERE dx_orderhdrnumber = convert(int, @ord_number)
		 AND dx_importid = 'dx_204' AND dx_processed = 'RESERV'
	
	--exit if update records not found
	IF @dx_sourceDate = '12/31/2049 23:59:59' RETURN	
	
	--insert company data into the temp table to process
	INSERT INTO @companyData
		SELECT cmp_id,
				dx_ident
				,dx_field001
				,dx_field004
				,dx_field005
				,dx_field006
				,dx_field007
				,dx_field008
				,dx_field009
				,dx_field010
				,dx_field011
				,null
				,null
		FROM dx_archive WITH(NOLOCK)
		LEFT JOIN company C1 (NOLOCK) on C1.cmp_id = 
		(
			select top 1 C2.cmp_id
			FROM Company C2 (NOLOCK) 
			WHERE C2.cmp_altid = dx_field013
		)
			WHERE dx_sourcedate = @dx_sourceDate  AND dx_importid =  'dx_204'
			AND dx_orderhdrnumber = convert(int, @ord_number)
			AND dx_field001 =  '06'
			AND IsNull(dx_field013,'') > ''
			AND IsNull(C1.cmp_id,'') > ''
			AND IsNull(dx_field007,'') > ''
			AND IsNull(dx_field008,'') > ''

			
			--insert 07 data into the temp table to process
	INSERT INTO @companyData
		SELECT '',
				dx_ident
				,dx_field001
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,dx_field004
				,dx_field006
		FROM dx_archive WITH(NOLOCK)
		
			WHERE dx_sourcedate = @dx_sourcedate AND dx_importid =  'dx_204'
			AND dx_orderhdrnumber = convert(int, @ord_number)
			AND dx_field001 =  '07'
			
		-- prepare apostrophes, that may be embedded in the column values, for the inline SQL
		update @companyData
				set cmp_name = replace(cmp_name,'''', ''''''),
					cmp_address1 = replace(cmp_address1,'''', ''''''),
					cmp_address2 = replace(cmp_address2,'''', ''''''),
					cmp_cityname = replace(cmp_cityname,'''', ''''''),
					stp_contact = replace(stp_contact,'''', '''''')
					
		
		SELECT  @loopcounter = ISNULL((SELECT COUNT(*) FROM @companyData where dx_field001='06'),0)	
		SET @companyCounter = 1
				
		--process company records
		WHILE @loopCounter > 0 AND @companyCounter <= @loopCounter
		BEGIN
			SELECT @cmp_id = cmp_id,
					@dx_ident=dx_ident,
					 @cmp_name = cmp_name,
					 @cmp_address1 = cmp_address1,
					 @cmp_address2 = cmp_address2,
					 @cmp_cityname = cmp_cityname,
					 @cmp_state = cmp_state,
					 @cmp_zip = cmp_zip,
					 @cmp_country = cmp_country,
					 @cmp_primaryphone = cmp_primaryphone
			FROM	@companyData	
			WHERE	rec_id = @companyCounter
			and dx_field001='06'
		
		
		declare @next06rec int
		declare @next07rec int
		set @next07rec=0
		select top 1 @next06rec= dx_ident from  @companyData where dx_ident > @dx_ident and dx_field001='06' order by dx_ident asc
		if (@dx_ident=@next06rec)
		begin
		select @next07rec = dx_ident from @companyData where dx_ident > @dx_ident   and dx_field001='07'
		end
		else
		begin
		select @next07rec = dx_ident from @companyData where dx_ident between @dx_ident and @next06rec  and dx_field001='07'
		end
	
			
			if (@next07rec <> 0)
				begin
						SELECT 
							 @stp_contact = stp_contact,
							 @stp_phonenumber = stp_phonenumber
								FROM	@companyData	
								WHERE	dx_ident = @next07rec
								and dx_field001='07'
				end
			else
				begin 
							set @stp_contact = null
							set @stp_phonenumber = null
				end
			
			
		declare @ret int	
		declare @cty_code int	
		declare @cty_nmstct varchar(25)
		EXEC @ret = dx_add_city
 				@cmp_cityname,
				@cmp_state,
				@cmp_zip,
				null,
				@cmp_country, 
				@cty_code  OUTPUT,
				@cty_nmstct  OUTPUT

		
		SET @sql = N'UPDATE company SET '		
		SET @sql = @sql + N'cmp_name = ''' + @cmp_name + ''', '
		SET @sql = @sql + N'cmp_address1 = ''' + @cmp_address1 + ''', '
		SET @sql = @sql + N'cmp_address2 = ''' + @cmp_address2 + ''', '
		SET @sql = @sql + N'cmp_city = ' + convert(varchar(12), @cty_code) + ', '
		SET @sql = @sql + N'cty_nmstct = ''' + @cty_nmstct + ''', '
		SET @sql = @sql + N'cmp_state = ''' + @cmp_state + ''', '
		SET @sql = @sql + N'cmp_zip = ''' + @cmp_zip + ''', '
		SET @sql = @sql + N'cmp_country = ''' + @cmp_country + ''', '
		SET @sql = @sql + N'cmp_primaryphone = ''' + @cmp_primaryphone + ''', '
		SET @sql = @sql + N'cmp_quickentry = ''Y'' '

		SET @where =  N'WHERE cmp_id = ''' + @cmp_id + ''' '	
		SET @where = @where + N'AND (IsNull(cmp_name,'''') <> ''' + @cmp_name + ''' '
		SET @where = @where + N'OR IsNull(cmp_address1,'''') <> ''' + @cmp_address1 + ''' '
		SET @where = @where + N'OR IsNull(cmp_address2,'''') <> ''' + @cmp_address2 + ''' '
		SET @where = @where + N'OR IsNull(cmp_city,0) <> ' + convert(varchar(12), @cty_code) + ' '
		SET @where = @where + N'OR IsNull(cty_nmstct,'''') <> ''' + @cty_nmstct + ''' '
		SET @where = @where + N'OR IsNull(cmp_state,'''') <> ''' + @cmp_state + ''' '
		SET @where = @where + N'OR IsNull(cmp_zip,'''') <> ''' + @cmp_zip + ''' '
		SET @where = @where + N'OR IsNull(cmp_country,'''') <> ''' + @cmp_country + ''' '
		SET @where = @where + N'OR IsNull(cmp_primaryphone,'''') <> ''' + @cmp_primaryphone + ''' )'
		
		SET @sql = @sql + @where
		PRINT @sql
		EXEC sp_executesql @sql;

		--adjust length to match stops table
		SET @cmp_address1 = left(@cmp_address1, 40)
		SET @cmp_address2 = left(@cmp_address2, 40)


		SET @sql = N'UPDATE STOPS SET '
		SET @sql = @sql + N'stp_city = ' + convert(varchar(12), @cty_code) + ', '
		SET @sql = @sql + N'cmp_name = ''' + @cmp_name + ''', '
		SET @sql = @sql + N'stp_state = ''' + @cmp_state + ''', '
		SET @sql = @sql + N'stp_phonenumber = ''' +  ISNULL(@stp_phonenumber,@cmp_primaryphone)     + ''', '
		SET @sql = @sql + N'stp_contact = ''' + isnull(@stp_contact,'') + ''', '
		SET @sql = @sql + N'stp_address = ''' + isnull(@cmp_address1,'') + ''', '
		SET @sql = @sql + N'stp_address2 = ''' + isnull(@cmp_address2,'') + ''' '
		
		

		SET @where =  N'WHERE cmp_id = ''' + @cmp_id + ''' '	
		SET @where = @where + N'AND ord_hdrnumber = ' + @ord_number + ' '
		SET @where = @where + N'AND (IsNull(cmp_name,'''') <> ''' + @cmp_name + ''' '
		SET @where = @where + N'OR IsNull(stp_address,'''') <> ''' + isnull(@cmp_address1,'') + ''' '
		SET @where = @where + N'OR IsNull(stp_address2,'''') <> ''' + isnull(@cmp_address2,'') + ''' '
		SET @where = @where + N'OR IsNull(stp_city,0) <> ' + convert(varchar(12), @cty_code) + ' '
		SET @where = @where + N'OR IsNull(stp_state,'''') <> ''' + @cmp_state + ''' '
		SET @where = @where + N'OR IsNull(stp_contact,'''') <> ''' + isnull(@stp_contact,'') + ''' '
		SET @where = @where + N'OR IsNull(stp_phonenumber,'''') <> ''' + isnull(@cmp_primaryphone,'') + ''' )'
		SET @sql = @sql + @where
		PRINT @sql		
		EXEC sp_executesql @sql;
		
		SET @companyCounter = @companyCounter + 1
	END

	if exists(select * from company where cmp_quickentry='N' and cmp_updatedby = 'dx_add_company' and (cmp_createdate > Dateadd(n, -2, getdate())))

	begin
		update company set cmp_quickentry='Y' where cmp_createdate > Dateadd(n, -2, getdate())
	end

END

GO
GRANT EXECUTE ON  [dbo].[ltsl_postprocess_companyUpdate] TO [public]
GO
