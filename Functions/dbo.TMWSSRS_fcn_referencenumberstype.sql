SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




create function [dbo].[TMWSSRS_fcn_referencenumberstype]
(	
	@ref_tablekey int,
	@ref_table varchar(18),
	@ref_type varchar(6),
	@ShowType_YN char(1),
	@LineBreak_YN char(1)
)

returns varchar(8000)

as
/*
Function TMWSSRS_fcn_referencenumberstype
11/5/2014 New version 
JR
Parameters:
	@ref_tablekey int, -- the table key for the ref numbers
	@ref_table varchar(18), -- the table name for the ref numbers
	@ref_type varchar(6), -- limit to this type. If blank, show all types
	@ShowType_YN char(1), -- add a string showing the ref type
	@LineBreak_YN char(1) -- Should there be a carriage return between numbers. If not use a comma and a space
	
	Example of call
	select dbo.[TMWSSRS_fcn_referencenumberstype](ord_hdrnumber,'orderheader','PO#','Y','N')
	from orderheader ord where ord_startdate>'1/1/2014'

*/

begin
	--declare @num varchar(12)
	DECLARE @ReturnString varchar(8000),@RefCount int,@Refid int

	DECLARE @RefList table 
		(
		ref_id int,
		ref_type varchar(6),
		ref_number varchar(30),
		endofline varchar(2) -- comma or line feed
		)
		
	INSERT INTO @RefList
	select  ref.ref_id,
		isnull(ref.ref_type,''),
		isnull(ref.ref_number,''),
		case @LineBreak_YN
		when 'Y' then CHAR(10) + CHAR(13)
		else ', '
		end
	from referencenumber ref with(nolock)
	WHERE 
	ref.ref_table = @ref_table
	and ref.ref_tablekey = @ref_tablekey
	and (ref.ref_type = @ref_type or @ref_type='' or @ref_type is null)
	order by ref.ref_sequence
	
	set @RefCount = (select count(ref_id) from @RefList)
	
	while @RefCount>0
		BEGIN
			select top 1 @Refid=ref_id from @RefList
			
			if @RefCount>1
				BEGIN					
					set @ReturnString=ISNULL(@ReturnString,'') + 
					(select top 1 
					case @ShowType_YN
					when 'Y' then ref_type + ' ' +	ref_number	+ endofline
					else ref_number	+ endofline
					end
					from @RefList
					where ref_id=@Refid)
				END
			If @RefCount=1 -- last one
			BEGIN					
					set @ReturnString=ISNULL(@ReturnString,'') + 
					(select top 1 
					case @ShowType_YN
					when 'Y' then ref_type + ' ' +	ref_number
					else ref_number						end
					from @RefList
					where ref_id=@Refid)
			END
			
			delete @RefList where ref_id=@Refid
			set @RefCount = (select count(ref_id) from @RefList)
					
		END

RETURN ISNULL(@ReturnString,'')

end


GO
