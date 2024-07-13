import React from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';

const Spinner: React.FC = () => {
	return (
		<div className="spinner-overlay d-flex justify-content-center align-items-center">
			<div className="spinner-border text-primary" role="status">
				<span className="visually-hidden">Loading...</span>
			</div>
		</div>
	);
};

export default Spinner;
