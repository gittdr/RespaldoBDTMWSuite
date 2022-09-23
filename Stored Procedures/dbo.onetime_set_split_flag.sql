SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[onetime_set_split_flag] 
as

declare @mov		int,
	@ret		int,
	@li_ctr		int

select @li_ctr = 0
select @mov = 0

select 'This process may take a while.........'
select 'Records to process.......' ,count(distinct mov_number) from legheader

While 1 = 1
Begin


	SELECT @mov = min(l.mov_number)
	from legheader l
	where l.mov_number > @mov 

	if @mov is null
	 break
	
	select @li_ctr = @li_ctr + 1
--	select 'Now processing Move', @mov ,'Counter:', @li_ctr

	begin tran split
	EXEC @ret = set_split_flag @mov
	IF @ret != 0 
	BEGIN
     		IF @@error != 0 
     		BEGIN
         		ROLLBACK TRAN split
          		RETURN (@@error)
     		END
     		ELSE
    		BEGIN
          		COMMIT TRAN split
          		IF @@error != 0
          		BEGIN
               			ROLLBACK TRAN split
               			RETURN (@@error)
          		END
     		END
	END
	COMMIT TRAN split


End


GO
GRANT EXECUTE ON  [dbo].[onetime_set_split_flag] TO [public]
GO
