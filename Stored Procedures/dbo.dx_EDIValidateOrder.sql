SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_EDIValidateOrder]
	@p_OrderHeaderNumber varchar(50),
	@@rev1 varchar(6)  = '' output,
	@@rev2 varchar(6)  = '' output,
	@@rev3 varchar(6)  = '' output,
	@@rev4 varchar(6)  = '' output,
	@@webcompany varchar(30)  = '' output,
	@@weborder varchar(30)  = '' output,
	@@forcerevs int  = 0 output
as

 /*******************************************************************************************************************  
  Object Description:
  dx_EDIValidateOrder

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  09/07/2016   David Wilks      64545        support RowSecurity GI Setting
********************************************************************************************************************/

declare @gi1 char(1), @gi2 char(1), @gi3 char(1), @gi4 char(1), 
		@dx_ident int, @v_rowsecurity char(1), @v_rowsecurityforltsl2 char(1), @tmwuser varchar(255)

set @@forcerevs = 0
		
select @v_rowsecurity = upper(left(gi_string1,1)) from generalinfo where gi_name = 'RowSecurity'
if isnull(@v_rowsecurity,'N') <> 'Y' select @v_rowsecurity = 'N'

select @v_rowsecurityforltsl2 = upper(left(gi_string1,1)) from generalinfo where gi_name = 'RowSecurityForLTSL2'
if isnull(@v_rowsecurityforltsl2 ,'N') <> 'Y' select @v_rowsecurityforltsl2 = 'N'


if @v_rowsecurityforltsl2 = 'Y'
begin
	--exec gettmwuser @tmwuser OUTPUT  AR 07.01.09
	exec dx_gettmwuser @tmwuser OUTPUT
	if exists (select 1 from UserTypeAssignment where usr_userid = @tmwuser)
	begin
		declare @validbelongsto table (BelongsTo varchar(6))
		insert @validbelongsto (BelongsTo) values ('UNK')
		insert @validbelongsto (BelongsTo) select uta_type1 from UserTypeAssignment where usr_userid = @tmwuser
		if (select count(1) from orderheader 
			 where ord_hdrnumber = @p_OrderHeaderNumber
			   and isnull(ord_BelongsTo,'UNK') in (select BelongsTo from @validbelongsto)) = 0
		    return -1
	end
end

if @v_rowsecurity = 'Y'
begin
		if not exists (select 1 from orderheader ord 
		inner join RowRestrictValidAssignments_orderheader_fn() rsva on (ord.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
		where ord_hdrnumber = @p_OrderHeaderNumber)
		    return -1
end


select @dx_ident = max(dx_ident) from dx_archive
 where dx_importid = 'dx_204'
   and dx_orderhdrnumber = @p_OrderHeaderNumber
   and dx_field001 = '02'

   select @@rev1 = ord_revtype1
				 , @@rev2 = ord_revtype2
				 , @@rev3 = ord_revtype3
				 , @@rev4 = ord_revtype4
			  from orderheader
			 where ord_hdrnumber = @p_OrderHeaderNumber


if (select isnull(dx_field004,'') from dx_archive where dx_ident = @dx_ident) not in ('C','R')
begin
	select @gi1 = upper(left(gi_string1, 1))
		 , @gi2 = upper(left(gi_string2, 1))
		 , @gi3 = upper(left(gi_string3, 1))
		 , @gi4 = upper(left(gi_string4, 1))
	  from generalinfo
	 where gi_name = 'LTSLForceRevTypes'

	if @@ROWCOUNT = 1
	begin
		if isnull(@gi1,'N') = 'Y' or isnull(@gi2,'N') = 'Y' or isnull(@gi3,'N') = 'Y' or isnull(@gi4,'N') = 'Y'
		begin
			if (isnull(@gi1,'N') = 'Y' and isnull(@@rev1,'UNK') = 'UNK') select @@forcerevs = @@forcerevs + 8
			if (isnull(@gi2,'N') = 'Y' and isnull(@@rev2,'UNK') = 'UNK') select @@forcerevs = @@forcerevs + 4
			if (isnull(@gi3,'N') = 'Y' and isnull(@@rev3,'UNK') = 'UNK') select @@forcerevs = @@forcerevs + 2
			if (isnull(@gi4,'N') = 'Y' and isnull(@@rev4,'UNK') = 'UNK') select @@forcerevs = @@forcerevs + 1
		end
	end
end

declare @giors1 varchar(255), @giors2 varchar(255), @giors3 varchar(255)
	select @giors1 = upper(left(gi_string1, 1))
		 , @giors2 = upper(gi_string2)
		 , @giors3 = gi_string3
	  from generalinfo
	 where gi_name = 'OrderResponseService'

	 if @@ROWCOUNT = 1
	 begin
		if isnull(@giors1,'N') = 'Y' 
		begin
			declare @p_revType1       	varchar(256), 
					@p_revType2       	varchar(256), 
					@p_revType3       	varchar(256), 
					@p_revType4       	varchar(256),
					@p_orderresponse    int

			SELECT @p_revType1 = ',' + LTRIM(RTRIM(ISNULL(@@rev1, ''))) + ',' 
			SELECT @p_revType2 = ',' + LTRIM(RTRIM(ISNULL(@@rev2, ''))) + ',' 
			SELECT @p_revType3 = ',' + LTRIM(RTRIM(ISNULL(@@rev3, ''))) + ',' 
			SELECT @p_revType4 = ',' + LTRIM(RTRIM(ISNULL(@@rev4, ''))) + ',' 

			If  @giors2 = 'REVTYPE1'
				SET @p_orderresponse = CHARINDEX(@p_revType1, ',' + @giors3 + ',') 
			If  @giors2 = 'REVTYPE2'
				SET @p_orderresponse = CHARINDEX(@p_revType2, ',' + @giors3 + ',') 
			If  @giors2 = 'REVTYPE3'
				SET @p_orderresponse = CHARINDEX(@p_revType3, ',' + @giors3 + ',') 
			If  @giors2 = 'REVTYPE4'
				SET @p_orderresponse = CHARINDEX(@p_revType4, ',' + @giors3 + ',') 				
				
	
			if @p_orderresponse  > 0
			begin
				select @giors1 = upper(gi_string1)
					, @giors2 = upper(gi_string2)
				from generalinfo
				where gi_name = 'OrderResponseRefTypes'
				select @@webcompany = ref_number from referencenumber where ord_hdrnumber = @p_OrderHeaderNumber and ref_type = @giors1 
				select @@weborder = ref_number from referencenumber where ord_hdrnumber = @p_OrderHeaderNumber and ref_type = @giors2 
			end
		end
	 
end


GO
GRANT EXECUTE ON  [dbo].[dx_EDIValidateOrder] TO [public]
GO
