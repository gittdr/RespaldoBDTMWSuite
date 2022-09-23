SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[core_UpdateExpiration] (
	@exp_key int,
	@exp_idtype char(3),
	@exp_id varchar(8),
	@exp_code varchar(6),
	@exp_description varchar(100),
	@exp_priority varchar(6),
	@exp_expirationdate datetime,
	@exp_city int,
	@exp_routeto varchar(12),
	@exp_completed char(1),
	@exp_compldate datetime,
	@tmstmp timestamp,
	@newtmstmp timestamp output,
	@createmove varchar(1) output
) as

update expiration
set
	exp_idtype=@exp_idtype,
	exp_id=@exp_id,
	exp_code=@exp_code,
	exp_description=@exp_description,
	exp_priority=@exp_priority,
	exp_expirationdate=@exp_expirationdate,
	exp_city=@exp_city,
	exp_routeto=@exp_routeto,
	exp_completed=@exp_completed,
	exp_compldate=@exp_compldate
where
	exp_key=@exp_key
	and
	[timestamp]=@tmstmp

if (@@rowcount=0)
    raiserror('Row has been edited by another user', 16, 1)

select @newtmstmp = timestamp
from Expiration
where exp_key=@exp_key

select @createmove = IsNull(create_move,'')
from labelfile
where labeldefinition='Exp' + @exp_idtype
and abbr=@exp_code

GO
GRANT EXECUTE ON  [dbo].[core_UpdateExpiration] TO [public]
GO
