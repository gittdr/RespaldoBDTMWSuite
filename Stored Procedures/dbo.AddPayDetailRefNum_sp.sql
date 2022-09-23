SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

Create procedure [dbo].[AddPayDetailRefNum_sp] (@pyd_number integer, 
                                            @ref_type		varchar (6),
                                            @ref_number varchar (30))
AS
declare  @pyd_ref_type as varchar (6),
         @pyd_ref_number as varchar (30), 
         @seq as integer
SET NOCOUNT ON

select @pyd_ref_type = pyd_refnumtype, @pyd_ref_number = pyd_refnum
    from paydetail 
    where pyd_number = @pyd_number
if @@rowcount = 0 return
if @pyd_ref_type is null 
    update paydetail 
      set pyd_refnumtype = @ref_type, 
          pyd_refnum = @ref_number
      where pyd_number = @pyd_number

select @seq = max (ref_sequence) + 1
    from referencenumber 
    where ref_tablekey = @pyd_number
    and ref_table = 'paydetail'

if @seq is null select @seq = 1 

insert into referencenumber (ref_tablekey, ref_type, ref_number, ref_sequence, ord_hdrnumber, ref_table, last_updateby, last_updatedate)
   values (@pyd_number, @ref_type, @ref_number, @seq, 0, 'paydetail', suser_sname(), current_timestamp)

GO
GRANT EXECUTE ON  [dbo].[AddPayDetailRefNum_sp] TO [public]
GO
