SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Function [dbo].[fnc_TMWRN_TotalDriverExpirations] 
(
	@BeginDay datetime,
	@EndDay datetime,
	@DriverID varchar(150),
	@PriorityStatus varchar(150)= '9'
)

Returns int
As

Begin	

Declare @ExpirationCount int

SELECT @PriorityStatus =	Case 
							When Left(@PriorityStatus ,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@PriorityStatus , ''))) + ',' 
							Else @PriorityStatus  End

Set @ExpirationCount = 0

select @ExpirationCount = sum(EXP)
FROM
(
SELECT EXP = ISNULL((	SELECT MIN(1) 
						FROM Expiration (NOLOCK) 
						WHERE (@PriorityStatus = ',,' OR CHARINDEX(',' + RTRIM( exp_priority ) + ',', @PriorityStatus) > 0) 
							AND exp_id = @DriverID and exp_idtype = 'DRV'
							AND PlainDate BETWEEN exp_expirationdate and exp_compldate
							AND exp_expirationdate >= @BeginDay
					),0)
FROM METRICBUSINESSDAYS
WHERE PlainDate BETWEEN @BeginDay and @EndDay
) as xx



Return @ExpirationCount
End


GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_TotalDriverExpirations] TO [public]
GO
