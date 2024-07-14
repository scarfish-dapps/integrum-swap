import LimitSwap from "../components/limit/LimitSwap";
import OrdersHistory from "../components/limit/OrdersHistory";

function Limit () {
	return (
		<div style={{padding: '0 50px'}} className="d-inline-flex w-100">
			<LimitSwap />
			<OrdersHistory/>
		</div>
		
	);
}

export default Limit;