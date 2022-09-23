SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[core_CreateExpiration] (
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
	@newkey int output,
	@createmove varchar(1) output
) as
	
insert expiration
(
	exp_idtype,
	exp_id,
	exp_code,
	exp_description,
	exp_priority,
	exp_expirationdate,
	exp_city,
	exp_routeto,
	exp_completed,
	exp_compldate
)
values
(
	@exp_idtype,
	@exp_id,
	@exp_code,
	@exp_description,
	@exp_priority,
	@exp_expirationdate,
	@exp_city,
	@exp_routeto,
	@exp_completed,
	@exp_compldate
)

select @newtmstmp=timestamp, @newkey=exp_key
from Expiration
where exp_key=SCOPE_IDENTITY()

select @createmove = IsNull(create_move,'')
from labelfile
where labeldefinition='Exp' + @exp_idtype
and abbr=@exp_code

GO
GRANT EXECUTE ON  [dbo].[core_CreateExpiration] TO [public]
GO
