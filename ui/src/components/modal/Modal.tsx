import React from 'react';

interface ModalComponentProps {
	show: boolean;
	handleClose: () => void;
	txHash: string;
	title: string
}

const ModalComponent: React.FC<ModalComponentProps> = ({ show, handleClose, txHash, title }) => {
	return (
		<div className={`modal ${show ? 'show' : ''}`} style={{ display: show ? 'block' : 'none' }} tabIndex={-1}>
			<div className="modal-dialog">
				<div className="modal-content">
					<div className="modal-header">
						<h5 className="modal-title text-center">{title}</h5>
						<button type="button" className="btn-close" onClick={handleClose} aria-label="Close"></button>
					</div>
					<div className="modal-body">
						<p>View on explorer:</p>
						<p>
							<a href={`https://sepolia.arbiscan.io/tx/${txHash}`} target="_blank"
							   rel="noopener noreferrer">
								{`https://sepolia.arbiscan.io/tx/${txHash}`}
							</a>
						</p>
					</div>
					<div className="modal-footer">
						<button type="button" className="btn btn-secondary" onClick={handleClose}>Close</button>
					</div>
				</div>
			</div>
		</div>
	);
};

export default ModalComponent;
