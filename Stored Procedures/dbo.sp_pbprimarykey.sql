SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[sp_pbprimarykey]
-------------------------------------------------------
--pts 3278 - this proc, although a PB proc, IS required 
--by powersuite for the executable environment! 
-------------------------------------------------------
@tabname varchar(92)                                                        
as
declare @tabid int                                                      
                                                                    
select @tabid = object_id(@tabname)

                                          
if @tabid is NULL
begin
return
end
else
                                               
begin
select k.keycnt,
objectkey1 = col_name(k.id, key1),
objectkey2 = col_name(k.id, key2),
objectkey3 = col_name(k.id, key3),
objectkey4 = col_name(k.id, key4),
objectkey5 = col_name(k.id, key5),
objectkey6 = col_name(k.id, key6),
objectkey7 = col_name(k.id, key7),
objectkey8 = col_name(k.id, key8)
from syskeys k, master.dbo.spt_values v
where  k.type = v.number and v.type =  'K'
and k.type = 1 and k.id = @tabid
return
end

GO
GRANT EXECUTE ON  [dbo].[sp_pbprimarykey] TO [public]
GO
