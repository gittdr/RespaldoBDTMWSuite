SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_load_tollboth_sp] @tb_name varchar(25), @number int, @parmlist varchar(254) AS 

DECLARE @matchrows  integer
	
if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if exists (select	tb_name        as 'name',
					tb_ident       as 'code',
					tb_vendor_name as 'vendor',
					tb_status      as 'status'
			  from tollbooth
			 where tb_status <> 'OUT'
			   and tb_name like @tb_name + '%')
	select @matchrows = 1
else
	select @matchrows = 0


if @matchrows = 0
	select	tb_name        as 'name',
			tb_ident       as 'code',
			tb_vendor_name as 'vendor',
			tb_status      as 'status'
	  from tollbooth
	 where tb_name = 'UNKNOWN'
else
	select	tb_name        as 'name',
			tb_ident       as 'code',
			tb_vendor_name as 'vendor',
			tb_status      as 'status'
	  from tollbooth
	 where tb_status <> 'OUT'
	   and tb_name like @tb_name + '%'
     order by tb_name

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_load_tollboth_sp] TO [public]
GO
